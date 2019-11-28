//
//  ViewController.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/27/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import UIKit
import RealmSwift
class HomeViewController: UIViewController {
    
    //MARK: helper outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var loadingStackView: UIStackView!
    var tag = ""
    var pageCount = 1
    let realm = try! Realm()
    let reachability = try! Reachability()
    var searchPhotos : [Photo]?{
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.collectionView.reloadData()
            }
        }
    }
    var localPhotos = [LocalPhoto](){
        didSet{
            DispatchQueue.main.async { [unowned self] in
                self.collectionView.reloadData()
            }
        }
    }
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //Mark:- hide keyboard when tap arround
        hideKeyboardWhenTappedAround()
        //MARK:- register cell from nib in collection view
        collectionView.registerCellNib(cellClass: SearchResultsCell.self)
        //MARK:- start listen to reachability notifier
        startReachabilityNotifier()
    }
    
    //MARK:- register reachability for notification and start listen
    func startReachabilityNotifier(){
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    //MARK:- Fetch Result Request
    func fetchResult(tag :String){
        pageCount += 1
        loadingStackView.isHidden = false
        SearchServices.shared.fetchSearchResult(tag: tag, pageCount: pageCount){[weak self] (success, returnedPhotoModel) in
            guard let self = self else {return}
            self.loadingStackView.isHidden = true
            if success{
                guard let photos = returnedPhotoModel?.photos else {return}
                self.updateSearchResult(with: photos )
            }else {
                self.fetchLocalPreviousSearchResults(searchTag: self.tag)
            }
        }
    }
    
    //MARK: - Handle response result
    func updateSearchResult(with photos: [Photo]){
        if self.searchPhotos == nil {
            self.searchPhotos = photos
        }else {
            self.searchPhotos?.append(contentsOf: photos)
        }
    }
    
    //MARK:- clearing here old data search results with current running tasks
    func resetValuesForNewSearch(){
        /* -1- cancel current request */
        SearchServices.shared.cancelCurrentTask()
        /* -2- reset search photos  */
        self.searchPhotos = nil
        self.localPhotos.removeAll()
        /* -2- reset page count */
        pageCount = 1
    }
    
    //MARK: - save local photo in realm
    func saveLocally(localPhoto:LocalPhoto){
        DispatchQueue.main.async { [unowned self] in
            //first check item if exist locally to prevent store it again
            if !self.objectExist(id: localPhoto.id!){
                //save photo data locally
                try! self.realm.write {
                    self.realm.add(localPhoto)
                }
            }else {
                print("item exist")
            }
        }
    }
    
    //check if item already saved locally
    func objectExist (id: String) -> Bool {
        return realm.object(ofType: LocalPhoto.self, forPrimaryKey: id) != nil
    }
    
    deinit {
        reachability.stopNotifier()
    }
}
//MARK: - Conform CollectionView Delegate, Datasource
extension HomeViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchPhotos?.count ?? localPhotos.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:
        IndexPath) -> UICollectionViewCell {
        //MARK: - Dequeue cell
        let cell = collectionView.dequeue(indexPath: indexPath) as SearchResultsCell
        //MARK: - update cell data
        updateData(for: cell,with: indexPath.row)
        //MARK: - return cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if reachability.connection != .unavailable {
            NavigationManager.shared.navigateToDetailScreen(self, localPhoto:nil, onlinePhoto: searchPhotos![indexPath.row])
        }else{
            NavigationManager.shared.navigateToDetailScreen(self, localPhoto:localPhotos[indexPath.row], onlinePhoto: nil)
        }
    }
    
    //MARK: - update cell data with online or Ofline data
    func updateData(for cell:SearchResultsCell,with row:Int){
        
        if let photo =  searchPhotos?[row]{
            photo.tag = self.tag
            cell.photo = photo
            
            //MARK: - Closure to listen to image downloading to store in local Storage
            cell.saveLocalPhoto = { [weak self] localPhoto in
                guard let self = self else {return}
                self.saveLocally(localPhoto: localPhoto)
            }
        }else {
            //MARK: - assign local photo
            cell.localPhoto = localPhotos[row]
        }
        
    }
    
}
//MARK: - Conform CollectionView flow layout deleget
extension HomeViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // minus 20 because of iner item space 10 and left and right margin 10
        return CGSize(width: (collectionView.frame.width / 2) - 20, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
//MARK: - Conform search bar delegate
extension HomeViewController:UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetValuesForNewSearch()
        tag = ""
        self.collectionView.reloadData()
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /* 1- Validate Search text */
        guard let text = searchBar.text?.removeSpace,
            text.isNotEmpty  else {
                Common.shared.showNotificationMessage(message: "Please type keyword to search result.", type: .error,viewController:self)
                return
        }
        /* 2- assign tag from Search text */
        resetValuesForNewSearch()
        /* 3- assign tag from Search text */
        tag = text
        /* 4- search for this tag */
        self.fetchResult(tag: self.tag)
    }
    //Search by tag in local storage by realm
    func fetchLocalPreviousSearchResults(searchTag:String){
        //create query fromat
        let query = NSPredicate(format:"tag == %@",searchTag)
        //retrieve with filter
        let photosWithTag = Array(realm.objects(LocalPhoto.self).filter(query))
        //append from Result<LocalPhoto> to [LocalPhoto]
        photosWithTag.forEach { (localPhoto) in
            self.localPhotos.append(LocalPhoto(id: localPhoto.id!, title: localPhoto.title!, tag: localPhoto.tag!, image: localPhoto.image!))
        }
        //If there is no in local storage show notification error message
        if self.localPhotos.count == 0 {
            Common.shared.showNotificationMessage(message: "Please check your Internet connection or try again.", type: .error,viewController:self)
        }
    }
}

//MARK: - Scrollview Delegate
extension HomeViewController: UIScrollViewDelegate {
    //MARK :- Getting user scroll down event here
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height)){
            //Start locading new data from here
            if reachability.connection != .unavailable{
                fetchResult(tag: tag)
            }
        }
    }
}

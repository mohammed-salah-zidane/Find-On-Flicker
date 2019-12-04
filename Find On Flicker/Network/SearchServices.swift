//
//  SearchServices.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/28/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
class SearchServices{
    
    static let shared = SearchServices()
    private init(){
        
    }
    var request:DataRequest?
    
    //MARK:- Fetch search result from the API
    func fetchSearchResult(tag:String,pageCount:Int, _ completion:@escaping(_ status:Bool, _ photosModel:PhotosModel?)->()){
        /* 1 - API method arguments */
        let paramters = refactoringParamters(tag: tag, pageCount: pageCount)
        /* 2 - API request */
        request = Alamofire.SessionManager.default.request(Common.shared.BASE_URL, method: .get,parameters:paramters as Parameters, encoding: URLEncoding.default)
            .responseJSON { [unowned self] (response) in
                switch response.result{
                case  .failure:
                    completion(false,nil)
                case .success:
                    let decoder = JSONDecoder()
                    do {
                        
                        //decode json with codable protocol
                        let responseModel = try decoder.decode(SearchResultsModel.self, from: response.data!)
                        //safe unwraping photo model with guard
                        guard let photosModel = responseModel.photos,responseModel.state == "ok" else {
                            completion(false,nil)
                            return
                        }
                        //assign local images
                        self.checkIfLocalImageExist(in: photosModel.photos!)
                        //return with success and photo model
                        completion(true,photosModel)
                        return
                    }catch{
                        print(error.localizedDescription)
                        completion(false,nil)
                    }
                }
                
        }
        
    }
    
    //MARK: - assing the local image and prevent from download it again if it exist
    private func checkIfLocalImageExist(in photos:[Photo]){
        DispatchQueue.main.async {
            do {
                let realm = try Realm()
                let localPhotos = realm.objects(LocalPhoto.self)
                localPhotos.forEach({ (localPhoto) in
                    photos.forEach({ (photo) in
                        if photo.id == localPhoto.id{
                            photo.image = localPhoto.image
                        }
                    })
                })
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Cancel all previous tasks
    func cancelCurrentTask(){
        if request != nil {
            request?.cancel()
        }
        
    }
    //MARK:- Refactoring paramters url arguments
    func refactoringParamters(tag:String,pageCount:Int)->Parameters{
        
        return  [
            "method": Common.shared.METHOD_NAME,
            "api_key": Common.shared.API_KEY,
            "text": tag,
            "safe_search": "\(pageCount)",
            "extras": Common.shared.EXTRAS,
            "format": Common.shared.DATA_FORMAT,
            "nojsoncallback": Common.shared.NO_JSON_CALLBACK
        ]
    }
}

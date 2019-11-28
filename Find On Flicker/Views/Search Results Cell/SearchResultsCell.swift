//
//  SearchResultsCell.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/27/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import UIKit
import  RealmSwift
class SearchResultsCell: UICollectionViewCell {
    
    //Mark:- Helper Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageDescription: UILabel!
    
    var saveLocalPhoto:((LocalPhoto)->())?
    var localPhoto:LocalPhoto?{
        didSet {
            self.imageView.image = UIImage(data: self.localPhoto!.image!)
            self.imageDescription.text = self.localPhoto?.title
        }
    }
    var photo:Photo?{
        didSet{
            self.imageDescription.text = self.photo?.title
            if let image = self.photo?.image {
                //assign image from local data base if it downloded before
                self.imageView.image = UIImage(data:image)
            }else {
                self.imageView.nuke(url: self.photo?.url, { [unowned self] success in
                    guard let photo = self.photo else {return}
                    if success {
                        DispatchQueue.main.async { [unowned self] in
                            let photoToSave = LocalPhoto(id:photo.id!,title:photo.title!,tag:photo.tag!,image:(self.imageView.image?.pngData())!)
                            self.saveLocalPhoto!(photoToSave)
                        }
                    }
                })
                
            }
        }
        
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

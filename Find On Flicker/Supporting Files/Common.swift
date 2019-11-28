//
//  Common.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/27/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import Foundation
import UIKit
import GSMessages
class Common{
    
    //Mark Create Shared Instance from common
    static let shared = Common()
    private init(){
    }
    
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    let API_KEY = "2b0c653be6d638084307fd32489cb44a"
    let API_SECRET = "f11d39ecf986a4af"
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let GALLERY_ID = "5704-72157622566655097"
    let EXTRAS = "url_s"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    
    //MARK:- Show Notification Message
    func showNotificationMessage(message: String? =
        nil,type:GSMessageType?,viewController:HomeViewController){
        
        switch type {
        case .error?:
            viewController.collectionView.showMessage(message ?? "" , type: GSMessageType.error)
        case .success?:
            viewController.collectionView.showMessage(message ?? "" , type: GSMessageType.success)
        case .warning?:
            viewController.collectionView.showMessage(message ?? "" , type: GSMessageType.warning)
        default:
            break
        }
        
    }
    
}

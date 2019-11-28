//
//  NavigationManager.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/27/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import Foundation
import UIKit

//Mark:- Navigation manager to manage navigations between screens
enum NavigationManager{
    case shared
    func navigateToHomeScreen(_ viewController:UIViewController){
        guard let homeVC = Common.shared.mainStoryBoard.instantiateViewController(withIdentifier: "home") as? UINavigationController else {return}
        viewController.present(homeVC, animated: true ,completion: nil)
    }

    func navigateToDetailScreen(_ viewController:UIViewController,localPhoto:LocalPhoto?,onlinePhoto:Photo?){
        guard let details = Common.shared.mainStoryBoard.instantiateViewController(withIdentifier: "details") as? DetailsViewController else {return}
        if localPhoto != nil {
            details.localPhoto = localPhoto
        }
        if onlinePhoto != nil {
            details.onlinePhoto = onlinePhoto

        }
        viewController.present(details, animated: true ,completion: nil)
    }
    
}

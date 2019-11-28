//
//  UIviewController.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/27/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import Foundation
import UIKit

enum ErrorType {
    case unvalidatedText
    case network
}
extension UIViewController{
    typealias AlertCompletionHandler = () -> Void
    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func showAlert( message: String, errorType: ErrorType ,completionHandler: AlertCompletionHandler? = nil) {
        let alert = UIAlertController(title: "Oops!",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dissmis", style: .default, handler: { (alertAction) in
            if let theHandler = completionHandler ,errorType == .unvalidatedText{
                theHandler()
            }
        }))
        
        if errorType == .network {
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                if let theHandler = completionHandler,errorType == .network {
                    theHandler()
                }
            }))
        }
        weak var weakSelf = self
        DispatchQueue.main.async(execute: {
            //create textPrompt here in Main Thread
            weakSelf?.present(alert,animated: true,completion: nil)
        })
    }
}

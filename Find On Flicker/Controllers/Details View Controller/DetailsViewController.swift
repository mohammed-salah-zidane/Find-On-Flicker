//
//  DetailsViewController.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/28/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import UIKit
class DetailsViewController: UIViewController {
  
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var localPhoto:LocalPhoto?
    var onlinePhoto:Photo?
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        updateView()
    }
    
    //MARK: - update view 
    func updateView(){
        if self.onlinePhoto != nil {
            self.titleLabel.text = self.onlinePhoto?.title ?? ""
            if let image = self.onlinePhoto?.image {
                //assign image from local data base if it downloded before
                self.imageView.image = UIImage(data:image)
            }else {
                self.imageView.nuke(url: self.onlinePhoto?.url,{_ in})
            }
        }else {
            self.imageView.image = UIImage(data: self.localPhoto!.image!)
            self.titleLabel.text = self.localPhoto?.title
        }
    }
    
    //MARK :- Dismis View Controller
    @IBAction func didClosePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

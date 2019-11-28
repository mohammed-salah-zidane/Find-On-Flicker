//
//  SearchResultsModel.swift
//  Find On Flicker
//
//  Created by prog_zidane on 11/28/19.
//  Copyright © 2019 prog_zidane. All rights reserved.
//

import Foundation
import RealmSwift
class SearchResultsModel : Codable {
    
    let photos : PhotosModel?
    let state : String?
    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case state = "stat"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        photos = try values.decodeIfPresent(PhotosModel.self, forKey: .photos)
        state = try values.decodeIfPresent(String.self, forKey: .state)
    }
    
}
class PhotosModel : Codable {
    
    let page : Int?
    let pages : Int?
    let perpage : Int?
    let photos : [Photo]?
    let total : String?
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case photos = "photo"
        case total = "total"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        pages = try values.decodeIfPresent(Int.self, forKey: .pages)
        perpage = try values.decodeIfPresent(Int.self, forKey: .perpage)
        photos = try values.decodeIfPresent([Photo].self, forKey: .photos)
        total = try values.decodeIfPresent(String.self, forKey: .total)
    }
    
}
class Photo :  Codable {
    let farm : Int?
    let isfamily : Int?
    let isfriend : Int?
    let ispublic : Int?
    let owner : String?
    let secret : String?
    let server : String?
    var id : String? = nil
    var title : String? = nil
    var tag :String?
    var image :Data?
    var url :String {
        get {
            return "http://farm\(farm ?? 0).static.flickr.com/\(server ?? "")/\(id ?? "")_\(secret ?? "").jpg"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case farm = "farm"
        case id = "id"
        case isfamily = "isfamily"
        case isfriend = "isfriend"
        case ispublic = "ispublic"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case title = "title"
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        farm = try values.decodeIfPresent(Int.self, forKey: .farm)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        isfamily = try values.decodeIfPresent(Int.self, forKey: .isfamily)
        isfriend = try values.decodeIfPresent(Int.self, forKey: .isfriend)
        ispublic = try values.decodeIfPresent(Int.self, forKey: .ispublic)
        owner = try values.decodeIfPresent(String.self, forKey: .owner)
        secret = try values.decodeIfPresent(String.self, forKey: .secret)
        server = try values.decodeIfPresent(String.self, forKey: .server)
        title = try values.decodeIfPresent(String.self, forKey: .title)
    }
    
}

class LocalPhoto:Object{
    //For store those properties locally
    @objc dynamic var id : String? = nil
    @objc dynamic var title : String? = nil
    @objc dynamic var tag :String?
    @objc dynamic var image :Data?

    //PrimaryKey
    override class func primaryKey() -> String? {
        return "id"
    }
    //init 
    convenience init(id :String,title:String,tag:String,image:Data) {
        self.init()
        self.id = id
        self.title = title
        self.tag = tag
        self.image = image
    }
}

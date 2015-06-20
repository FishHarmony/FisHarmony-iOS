//
//  Ship.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/11/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class Ship {
    var name: String?
    var id: Int?
    var notes: String?
    var image: UIImage?
    var location: CLLocationCoordinate2D?
    var category: String?
    var hasName: Bool = true
    var hasNotes: Bool = true
    
    init(json: JSON) {
        name = json["ship_name"].string
        if name == nil {
            hasName = false
            name = "No Name On Record"
        }
        id = json["id"].intValue
        notes = json["notes"].string
        if notes == nil {
            hasNotes = false
            notes = ""
        }
        let imageString = json["image"].string
        if imageString != nil {
            let url = NSURL(string: imageString!)
            if url != nil {
                let data = NSData(contentsOfURL: url!)
                if data != nil {
                    image = UIImage(data: data!)
                }
            }
        }
        
        location = CLLocationCoordinate2D(latitude: NSString(string:(json["geolocation"]["latitude"].stringValue)).doubleValue, longitude: NSString(string:(json["geolocation"]["longitude"].stringValue)).doubleValue)
        category = json["category"].string
    }
    
}

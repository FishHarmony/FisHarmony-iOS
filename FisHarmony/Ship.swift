//
//  Ship.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/11/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import Foundation
import SwiftyJSON

class Ship {
    var name: String?
    var id: Int?
    var notes: String?
    var image: UIImage?
    var lat: String?
    var lon: String?
    var hasName: Bool = true
    var hasNotes: Bool = true
    var hasLocation: Bool = true
    
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
        //        image = json["image"].string
        image = nil
        lat = json["geolocation"]["latitude"].string
        lon = json["geolocation"]["longitude"].string
        if lon == nil || lat == nil {
            hasLocation = false
        }
    }
    
}

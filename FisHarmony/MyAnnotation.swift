//
//  MyAnnotation.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/7/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit
import MapboxGL

public let typeDictionary = [
    "Illegal Fishing"           : 1,
    "Bycatch"                   : 2,
    "Endangered Fish Sighting"  : 3,
    "Injured Mammal"            : 4
]

public let reverseTypeDictionary = [
    1:  "Illegal Fishing",
    2:  "Bycatch",
    3:  "Endangered Fish Sighting",
    4:  "Injured Mammal"
]


class MyAnnotation: NSObject, MGLAnnotation {
    internal var coordinate: CLLocationCoordinate2D
    internal var title: String!
    internal var subtitle: String!
  internal var type: Int!
    var tag: Int?
    internal var image: UIImage?
    
    init(location coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: Int, image: UIImage?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.image = image
    }
    
    func picture() -> String {
        var picture = ""
        switch self.type! {
        case typeDictionary["Illegal Fishing"]! :
            picture = "police-15"
            break
        case typeDictionary["Bycatch"]! :
            picture = "secondary_marker"
            break
        case typeDictionary["Endangered Fish Sighting"]! :
            picture = "secondary_marker"
            break
        case typeDictionary["Injured Mammal"]! :
            picture = "hospital-15"
            break
        default:
            break
        }
        return picture
        
    }
    
}

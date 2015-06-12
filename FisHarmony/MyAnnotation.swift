//
//  MyAnnotation.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/7/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit
import MapboxGL

public enum AnnotationType: Int {
    case Me = 0, OtherShip, InjuredMammel, IllegalActivity
}

class MyAnnotation: NSObject, MGLAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String!
    var subtitle: String!
    var type: AnnotationType!
    var tag: Int?
    
    init(location coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: AnnotationType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
    
    func picture() -> String {
        switch self.type! {
        case .Me:
            return "default_marker"
        case .OtherShip:
            return "ferry-11"
        case .InjuredMammel:
            return "hospital-11"
        case .IllegalActivity:
            return "secondary_marker"
        default:
            break
        }
        return ""

    }
    
}

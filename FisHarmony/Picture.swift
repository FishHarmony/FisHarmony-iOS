//
//  Picture.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/11/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public enum ReportingType: Int {
    case InjuredMammel = 0, OtherShip, FavoriteSpot, IllegalActivity, BiCatch
}

class Picture {
    var name: String?
    var coordinates: CLLocationCoordinate2D?
    var reportingType: ReportingType?
    var image: UIImage?
    
    init(name: String?, coordinates: CLLocationCoordinate2D?, type: ReportingType?, image: UIImage?) {
        self.name = name
        self.coordinates = coordinates
        self.reportingType = type
        self.image = image
    }
}

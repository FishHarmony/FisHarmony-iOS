//
//  InfoViewController.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/20/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class InfoViewController: UITableViewController {
    var image:UIImage?
    var notes: String?
    var latLon: CLLocationCoordinate2D?
    var shipName: String?
    var type: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.image == nil {
            if self.notes == nil {
                return 100
            }
            else {
                if indexPath.row == 0 {
                   return 100
                }
                else {
                    return 200
                }
            }
        }
        else if self.notes == nil {
            if indexPath.row == 0 {
                return UIScreen.mainScreen().bounds.width - 20
            }
            else {
                return 100
            }
        }
        else {
            if indexPath.row == 0 {
                return UIScreen.mainScreen().bounds.width - 20
            }
            else if indexPath.row == 1 {
                return 100
            }
            else {
                return 200
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 3
        if self.image == nil {
            count--
        }
        if self.notes == nil {
            count--
        }
        return count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

}
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
    
    func setUpInfoCell(tableView: UITableView) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("infoCell") as? UITableViewCell
        var shipNameLabel = cell?.viewWithTag(111) as? UILabel
        var typeLabel = cell?.viewWithTag(222) as? UILabel
        var locationLabel = cell?.viewWithTag(333) as? UILabel
        if (shipName != nil) {
            shipNameLabel?.text = "\(shipName!)"
        }
        else {
            shipNameLabel?.text = "No Ship Name"
        }
        if (type != nil) {
            typeLabel?.text = "\(type!)"
        }
        else {
            typeLabel?.text = "Undefined Report Type"
        }
        if (latLon != nil) {
            locationLabel?.text = "Lat:\(latLon!.latitude) Lon:\(latLon!.longitude)"
        }
        else {
            locationLabel?.text = "No Location Given"
        }
        return cell

    }
    
    func setUpNotesCell(tableView: UITableView) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("notesCell") as? UITableViewCell
        var notesView = cell?.viewWithTag(444) as? UITextView
        
        if (notes != nil) {
            notesView?.text = "\(notes!)"
        }
        else {
            notesView?.text = "No notes..."
        }
        return cell
        
    }
    
    func setUpImageCell(tableView: UITableView) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("imageCell") as? UITableViewCell
        var imageView = cell?.viewWithTag(10) as? UIImageView
        
        if image != nil {
            imageView?.image = image!
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        var imageView: UIImageView?
        var notesView: UITextView?
        var shipNameLabel: UILabel?
        var locationLabel: UILabel?
        var typeLabel: UILabel?


        if self.image == nil {
            if self.notes == nil {
                cell = setUpInfoCell(tableView)
            }
            else {
                if indexPath.row == 0 {
                    cell = setUpInfoCell(tableView)
                }
                else {
                    cell = setUpNotesCell(tableView)

                }
            }
        }
        else if self.notes == nil {
            if indexPath.row == 0 {
                cell = setUpImageCell(tableView)
            }
            else {
                cell = setUpInfoCell(tableView)

            }
        }
        else {
            if indexPath.row == 0 {
                cell = setUpImageCell(tableView)

            }
            else if indexPath.row == 1 {
                cell = setUpInfoCell(tableView)

            }
            else {
                cell = setUpNotesCell(tableView)
            }
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None

        return cell!
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

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
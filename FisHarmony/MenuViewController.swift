//
//  MenuViewControllerTableViewController.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/14/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate {
    func dragMenu(point: CGPoint)
    func closeMenu()
    func resetMenu()
}

protocol MenuViewControllerActionDelegate {
    func selectedMenuOption(optionIndex: Int)
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: MenuViewControllerDelegate?
    var actionDelegate: MenuViewControllerActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red:26/255.0, green:26/255.0, blue:29/255.0, alpha:0.9)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.closeMenu()
        self.actionDelegate?.selectedMenuOption(indexPath.row)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return typeDictionary.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("optionCell", forIndexPath: indexPath) as! UITableViewCell
        
        var label: UILabel = cell.viewWithTag(123) as! UILabel
        if indexPath.row == 0 {
            label.text = ""
        }
        else {
            label.text = reverseTypeDictionary[indexPath.row]
        }
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    @IBAction func backViewTapped(sender: UITapGestureRecognizer) {
        self.delegate?.closeMenu()
    }

    
    @IBAction func draggingMenu(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        let newPos = CGPoint(x:sender.view!.center.x + translation.x, y:self.view.center.y)
        var maxX: CGFloat = 300
        if NSString(string: UIDevice.currentDevice().modelName).substringToIndex(4) == "iPad" {
            maxX = 500
        }
        switch sender.state {
        case .Changed:
            if newPos.x < maxX && newPos.x > (UIScreen.mainScreen().bounds.width)/2 {
                self.delegate?.dragMenu(newPos)
            }
            else if newPos.x <= (UIScreen.mainScreen().bounds.width)/2 {
                
            }
            else {
                self.delegate?.closeMenu()
            }
            break
        case .Ended:
            if newPos.x > maxX {
                self.delegate?.closeMenu()
            }
            else {
                self.delegate?.resetMenu()
            }
            break
        default:
            break
        }
        sender.setTranslation(CGPointZero, inView: self.view)
        
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}

//
//  PopUp.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/11/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import Foundation
import UIKit

class PopUp: UIView {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp(text: String, button: String) {

        self.layer.cornerRadius = 10.0
        self.gotItButton.layer.cornerRadius = 10.0
        self.textLabel.text = text
        self.gotItButton.titleLabel?.text = button
    }
    
    @IBAction func closePopUp(sender: AnyObject) {
        let frame1 = self.frame
        
        self.frame = CGRectMake(frame1.origin.x-5, frame1.origin.y-5, frame1.width+10, frame1.height+10)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        self.frame = CGRectMake(frame1.origin.x+(frame1.width/2), frame1.origin.y+(frame1.height/2), 0, 0)
        self.textLabel.hidden = true
        self.gotItButton.hidden = true
        UIView.commitAnimations()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.hidden = true
            self.frame = frame1
            self.textLabel.hidden = false
            self.gotItButton.hidden = false
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "yes", object: nil))
        })
    }
}

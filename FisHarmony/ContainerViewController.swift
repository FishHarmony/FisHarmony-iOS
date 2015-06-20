//
//  ContainerViewController.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/14/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit

// MARK: - Class
class ContainerViewController: UIViewController, ViewControllerDelegate, MenuViewControllerDelegate {
    // MARK: - Properties
    // MARK: Private Enums
    private enum SlideOutState {
        case BothCollapsed, LeftPanelExpanded, RightPanelExpanded
    }
    
    // MARK: Public Properties
    // MARK: Private Properties
    private var centerNavigationController: UINavigationController!
    private var centerViewController: ViewController!
    private var currentState: SlideOutState = .BothCollapsed
    private var rightViewController: MenuViewController?
    private var selectedIndexPath: NSIndexPath?
    private let centerPanelExpandOffset: CGFloat = (UIScreen.mainScreen().bounds.width-260) - UIScreen.mainScreen().bounds.width
    
    // MARK: - Methods
    // MARK: View Method Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.navigationBar.translucent = true
        centerNavigationController.navigationBar.barStyle = UIBarStyle.Black
        centerNavigationController.navigationBar.backgroundColor = UIColor.blackColor()
        centerNavigationController.navigationBar.tintColor = UIColor.whiteColor()
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        addRightPanelViewController()
        self.rightViewController?.view.hidden = true
        centerNavigationController.didMoveToParentViewController(self)
        
    }
    
    private func addRightPanelViewController() {
        if rightViewController == nil {
            rightViewController = UIStoryboard.rightViewController()
            rightViewController?.delegate = self
            addChildSidePanelController(rightViewController!)
            rightViewController?.actionDelegate = centerViewController
        }
    }
    
    private func addChildSidePanelController(sidePanelController: MenuViewController) {
        let frame = sidePanelController.view.frame
        sidePanelController.view.frame = CGRectMake(frame.width, frame.origin.y, frame.width, frame.height)
        view.addSubview(sidePanelController.view)
        //        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    private func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        self.view.bringSubviewToFront(self.rightViewController!.view)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.rightViewController!.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    private func animateRightPanel(#shouldExpand: Bool) {
        if shouldExpand == true {
            currentState = .RightPanelExpanded
            animateCenterPanelXPosition(targetPosition: 0)
        }
        else {
            if selectedIndexPath != nil {
                rightViewController?.tableView.deselectRowAtIndexPath(selectedIndexPath!, animated: false)
            }
            animateCenterPanelXPosition(targetPosition: UIScreen.mainScreen().bounds.width + 16) { finished in
                self.currentState = .BothCollapsed
            }
            
        }
    }
    
    // MARK: - Delegate Methods
    // MARK: CWProductShelfViewControllerDelegate Methods
    func toggleRightPanel() {
        self.rightViewController?.view.hidden = false
        let notAlreadyExpanded = (currentState != .RightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        
    }
    
    // MARK: MenuViewDelegate Methods
    func closeMenu() {
        animateRightPanel(shouldExpand: false)
    }
    
    func dragMenu(point: CGPoint) {
        var x = point.x - (self.rightViewController!.view.frame.width/2)
        self.animateCenterPanelXPosition(targetPosition: x, completion: nil)
    }
    
    func resetMenu() {
        animateRightPanel(shouldExpand: true)
    }
}

// MARK: - Extensions
// MARK: UIStoryboard Extension
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func rightViewController() -> MenuViewController? {
        var id = "Menu"
        if IS_IPAD {
            id = "MenuiPad"
        }
        return mainStoryboard().instantiateViewControllerWithIdentifier(id) as? MenuViewController
    }
    
    class func centerViewController() -> ViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("mainVC") as? ViewController
    }
}

private let DeviceList = [
    /* iPod 5 */          "iPod5,1": "iPod Touch 5",
    /* iPhone 4 */        "iPhone3,1":  "iPhone 4", "iPhone3,2": "iPhone 4", "iPhone3,3": "iPhone 4",
    /* iPhone 4S */       "iPhone4,1": "iPhone 4S",
    /* iPhone 5 */        "iPhone5,1": "iPhone 5", "iPhone5,2": "iPhone 5",
    /* iPhone 5C */       "iPhone5,3": "iPhone 5C", "iPhone5,4": "iPhone 5C",
    /* iPhone 5S */       "iPhone6,1": "iPhone 5S", "iPhone6,2": "iPhone 5S",
    /* iPhone 6 */        "iPhone7,2": "iPhone 6",
    /* iPhone 6 Plus */   "iPhone7,1": "iPhone 6 Plus",
    /* iPad 2 */          "iPad2,1": "iPad 2", "iPad2,2": "iPad 2", "iPad2,3": "iPad 2", "iPad2,4": "iPad 2",
    /* iPad 3 */          "iPad3,1": "iPad 3", "iPad3,2": "iPad 3", "iPad3,3": "iPad 3",
    /* iPad 4 */          "iPad3,4": "iPad 4", "iPad3,5": "iPad 4", "iPad3,6": "iPad 4",
    /* iPad Air */        "iPad4,1": "iPad Air", "iPad4,2": "iPad Air", "iPad4,3": "iPad Air",
    /* iPad Air 2 */      "iPad5,1": "iPad Air 2", "iPad5,3": "iPad Air 2", "iPad5,4": "iPad Air 2",
    /* iPad Mini */       "iPad2,5": "iPad Mini", "iPad2,6": "iPad Mini", "iPad2,7": "iPad Mini",
    /* iPad Mini 2 */     "iPad4,4": "iPad Mini", "iPad4,5": "iPad Mini", "iPad4,6": "iPad Mini",
    /* iPad Mini 3 */     "iPad4,7": "iPad Mini", "iPad4,8": "iPad Mini", "iPad4,9": "iPad Mini",
    /* Simulator */       "x86_64": "Simulator", "i386": "Simulator"
]

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = reflect(machine)
        var identifier = ""
        
        for i in 0..<mirror.count {
            if let value = mirror[i].1.value as? Int8 where value != 0 {
                identifier.append(UnicodeScalar(UInt8(value)))
            }
        }
        return DeviceList[identifier] ?? identifier
    }
}

public let IS_IPAD = NSString(string: UIDevice.currentDevice().modelName).substringToIndex(4) == "iPad"




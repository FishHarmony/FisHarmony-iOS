//
//  AppDelegate.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/5/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var parameters: [String: String]?
    private var imageData: NSData?
    private var notes: String?
    private var urlRequest: (URLRequestConvertible, NSData)?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let containerViewController = ContainerViewController()
        
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

       getReportsAndSend()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getReportsAndSend() -> Bool {
        var reportList: NSArray? = NSUserDefaults.standardUserDefaults().valueForKey("Reports") as? NSArray
    
        if reportList != nil {
            var reportsLeft: NSMutableArray? = NSMutableArray(array: reportList!)
            while reportsLeft!.count != 0 {
                var report: NSDictionary = reportsLeft!.objectAtIndex(0) as! NSDictionary
                self.imageData = report.valueForKey("imageData") as? NSData
                self.notes = report.valueForKey("notes") as? String
                self.parameters = report.valueForKey("parameters") as? [String: String]
                (reportsLeft! as NSMutableArray).removeObjectAtIndex(0)
                sendReport(makeRequest())
                
                NSUserDefaults.standardUserDefaults().removeObjectForKey("Reports")
                if reportsLeft!.count != 0 {
                    NSUserDefaults.standardUserDefaults().setValue(reportsLeft!.copy(), forKey: "Reports")
                }
            }
            return true
        }
        return false
    }
    
    func makeRequest() -> (URLRequestConvertible, NSData) {
        return urlRequestWithComponents("https://fisharmony.herokuapp.com/api/reports", parameters: parameters!, imageData: imageData!)
    }
    
    func sendReport(urlRequest: (URLRequestConvertible, NSData)) {
        Alamofire.upload(urlRequest.0, urlRequest.1).progress
            {
                (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            }.response
            {
                (request, response, _, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("ERROR \(error)")
                if error != nil {
                    var reportListHolder: NSArray? = NSUserDefaults.standardUserDefaults().valueForKey("Reports") as? NSArray
                    var reportList: NSMutableArray?
                    if reportListHolder == nil {
                        reportList = NSMutableArray()
                    }
                    else {
                        reportList = NSMutableArray(array: reportListHolder!)
                    }
                    var report: NSMutableDictionary = NSMutableDictionary()
                    report.setValue(self.imageData, forKey: "imageData")
                    report.setValue(NSString(string:self.notes!), forKey: "notes")
                    report.setValue(self.parameters, forKey: "parameters")
                    reportList?.addObject(report)
                    NSUserDefaults.standardUserDefaults().setValue(reportList!.copy(), forKey: "Reports")
                }
            }
    }
    
    func urlRequestWithComponents(urlString:String, parameters:[String: AnyObject], imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file_data\"; filename=\"file_data.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/jpg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }

}


//
//  ReportViewController.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/17/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AssetsLibrary

class ReportViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate {
    var type: String?
    private var notes: String?
    var location: CLLocation?
    private var direction: CLLocationDirection?
    var textView: UITextView!
    var sendButton: UIButton!
    var cameraButton: UIButton!
    var libraryButton: UIButton!
    private var chosenImage: UIImage?
    @IBOutlet weak var navItem: UINavigationItem!
    private var clearedPlaceHolder: Bool?
    private var imagePickerController: UIImagePickerController?
    private var urlRequest: (URLRequestConvertible, NSData)?
    private var parameters: [String: String]?
    private var imageData: NSData?
    var locationManager: CLLocationManager?
    private var requestedHeading: Bool = false

    
    override func viewDidLoad() {
        clearedPlaceHolder = false
        navItem.title = type!
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.whiteColor()
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.allowsEditing = false
        
        self.locationManager!.delegate = self
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        switch UIDevice.currentDevice().orientation{
        case .Portrait:
            self.locationManager!.headingOrientation = CLDeviceOrientation.Portrait
            break
            
        case .PortraitUpsideDown:
            self.locationManager!.headingOrientation = CLDeviceOrientation.PortraitUpsideDown
            break
            
        case .LandscapeLeft:
            self.locationManager!.headingOrientation = CLDeviceOrientation.LandscapeLeft
            break
            
        case .LandscapeRight:
            self.locationManager!.headingOrientation = CLDeviceOrientation.LandscapeRight
            break
            
        default:
            break
        }
        
        self.locationManager!.headingFilter = kCLHeadingFilterNone
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("pictureCell") as! UITableViewCell
            cameraButton = cell.viewWithTag(111) as! UIButton
            libraryButton = cell.viewWithTag(222) as! UIButton
            self.cameraButton.addTarget(self, action: "takePicture", forControlEvents: UIControlEvents.TouchUpInside)
            self.cameraButton.layer.cornerRadius = 5.0
            self.libraryButton.addTarget(self, action: "chosePicture", forControlEvents: UIControlEvents.TouchUpInside)
            self.libraryButton.layer.cornerRadius = 5.0
            self.libraryButton.layer.borderColor = UIColor(red: 48/255, green: 196/255, blue: 201/255, alpha: 1.0).CGColor
            self.libraryButton.layer.borderWidth = 0.5
            break
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("textCell") as! UITableViewCell
            textView = cell.viewWithTag(333) as! UITextView
            self.textView.delegate = self
            self.textView.layer.borderColor = UIColor(red: 48/255, green: 196/255, blue: 201/255, alpha: 1.0).CGColor
            self.textView.layer.borderWidth = 0.5
            self.textView.layer.cornerRadius = 5.0
            self.textView.text = "For your own safety, we urge you not to reveal your identity in these notes. This report is completely anonymous. (Type to clear this message)"
            break
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("sendCell") as! UITableViewCell
            sendButton = cell.viewWithTag(444) as! UIButton
            self.sendButton.layer.cornerRadius = 5.0
            self.sendButton.addTarget(self, action: "sendReport", forControlEvents: UIControlEvents.TouchUpInside)
            if self.chosenImage == nil {
                self.sendButton.enabled = false
                self.sendButton.backgroundColor = UIColor.grayColor()
            }
            else {
                if notes == nil {
                    notes = ""
                }
                self.sendButton.enabled = true
                self.sendButton.backgroundColor = UIColor(red: 48/255, green: 196/255, blue: 201/255, alpha: 1.0)
            }
            break
        default:
            cell = UITableViewCell()
            break
        }
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if self.chosenImage != nil {
                return "Your image has been uploaded"
            }
            else {
                return "Please upload a picture:"
            }
        case 1:
            return "Enter any additional information:"
        case 2:
            return ""
        default:
            break
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if IS_IPAD {
                return 80
            }
            return 50
        case 1:
            if IS_IPAD {
                return 500
            }
            return 210
        case 2:
            if IS_IPAD {
                return 80
            }
            return 50
        default:
            break
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if IS_IPAD {
            return 50
        }
        else {
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            break
        }
        return 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        var av = UIAlertView(title: "Delete Report?", message: "Are you sure you want to cancel this report? Your picture and changes will not be saved.", delegate: self, cancelButtonTitle: "Back to Report", otherButtonTitles: "Delete Report")
        av.tag = 123
        av.show()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if clearedPlaceHolder == false {
            textView.text = ""
            clearedPlaceHolder = true
        }
        else if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "For your own safety, we urge you not to reveal your identity in these notes. This report is completely anonymous. (Type to clear this message)"
            textView.textColor = UIColor.lightGrayColor()
            clearedPlaceHolder = false
        }
        else {
            notes = textView.text
        }
    }
    @IBAction func backgroundTapped(sender: AnyObject) {
        if self.textView != nil {
            self.textView.resignFirstResponder()
        }
    }
    
    func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            UIAlertView(title: "Camera Permissions Denied", message: "Enable Camera permissions via iOS Settings -> Fisharmony", delegate: self, cancelButtonTitle: "Ok").show()
        }
        else {
            imagePickerController!.sourceType = UIImagePickerControllerSourceType.Camera
        }
        requestedHeading = true
        self.locationManager!.startUpdatingHeading()
    }
    
    func chosePicture() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == false {
            UIAlertView(title: "Library Permissions Denied", message: "Enable Photo Library permissions via iOS Settings -> Fisharmony", delegate: self, cancelButtonTitle: "Ok").show()
        }
        else {
            imagePickerController!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        requestedHeading = true
        self.locationManager!.startUpdatingHeading()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        self.direction = newHeading.trueHeading
        if requestedHeading == true {
        self.presentViewController(imagePickerController!, animated: true, completion:{() -> Void in })
            requestedHeading = false
        }
        manager.stopUpdatingHeading()
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager!) -> Bool {
        return true
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == 123 {
            if buttonIndex == 1 {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.chosenImage = editingInfo[UIImagePickerControllerOriginalImage] as? UIImage
        
        //        self.imageView.image = chosenImage;
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage

        picker.dismissViewControllerAnimated(true, completion: nil)
        self.tableView.reloadData()
    }
    
    func makeRequest() {
        self.imageData = UIImageJPEGRepresentation(chosenImage, 1.0)
        let picture = Picture(name: "", coordinates: location?.coordinate, type: typeDictionary[type!], image: chosenImage)
        //        self.imageView.image = chosenImage;
        var dir: String?
        if self.direction == nil {
            dir = ""
        }
        else {
            dir = "\(self.direction!)"
        }
        self.parameters = [
            "report_category_id"    : "\(picture.reportingType!)",
            "latitude"              : "\(picture.coordinates!.latitude)",
            "longitude"             : "\(picture.coordinates!.longitude)",
            "notes"                 : "\(notes!)",
            "uploader_id"           : UIDevice.currentDevice().identifierForVendor.UUIDString,
            "direction"             : dir!
        ]
        
        //        var report: [String: [String: String]] = ["report": parameters]
        
        self.urlRequest = urlRequestWithComponents("https://fisharmony.herokuapp.com/api/reports", parameters: parameters!, imageData: imageData!)
        
    }
    
    func sendReport() {
        makeRequest()
        Alamofire.upload(urlRequest!.0, urlRequest!.1).progress
            {
                (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            }.response({
                (request, response, _, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("ERROR \(error)")
                if error != nil {
                    var av = UIAlertView(title: "Send Failed", message: "You don't have signal right now. Open this app when you get back to shore and we'll try again. You can still make new reports as well.", delegate: self, cancelButtonTitle: "Ok")
                    av.tag = 456
                    av.show()
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
            })
        self.navigationController?.popViewControllerAnimated(true)
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


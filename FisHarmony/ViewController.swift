//
//  ViewController.swift
//  FisHarmony
//
//  Created by Whitney Foster on 6/5/15.
//  Copyright (c) 2015 WhitneyFoster. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import Alamofire
import MapboxGL
import CoreLocation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explainerPopUp: PopUp!
    private var imagePickerController: UIImagePickerController?
    private var locationManager: CLLocationManager = CLLocationManager()
    private var direction: CLLocationDirection = 0.0
    private var mapView: MGLMapView?
    private var explained: Bool = false
    
    func mapView(mapView: MGLMapView!, symbolNameForAnnotation annotation: MGLAnnotation!) -> String! {
        switch (annotation as! MyAnnotation).type! {
        case .Me:
            return "harbor-11"
        case .OtherShip:
            return "ferry-11"
        case .InjuredMammel:
            return "hospital-11"
        case .IllegalActivity:
            return "police-11"
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.explainerPopUp.hidden = false
        
        mapView = MGLMapView(frame: view.frame)
        mapView?.accessToken = "pk.eyJ1IjoibWxhbmciLCJhIjoiYzliMjU3NTdiNTg1MGZlZjg1ODU1MjNlMGI3N2E5M2UifQ.PCxqsYuSx1a4bSeVp6pmnA"
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        explainerPopUp.setUp()
        var findMe: UIImageView = UIImageView(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 30, UIScreen.mainScreen().bounds.height - 30, 20, 20))
        
//        findMe.image = UIImage(named: "findMe")
//        findMe.layer.cornerRadius = 5.0
//        let gr = UIGestureRecognizer(target: self, action: "findMe")
//        findMe.addGestureRecognizer(gr)
//        self.view.addSubview(findMe)
//        findMe.bringSubviewToFront(self.mapView!)
//        findMe.setNeedsDisplay()
        
        mapView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        // set the map's center coordinate
        // long beach: 33.7717 N, 118.1934 W
        mapView!.setCenterCoordinate(CLLocationCoordinate2D(latitude:33.7717, longitude:-118.1934), zoomLevel: 15, animated:false)
        view.addSubview(mapView!)
        mapView!.showsUserLocation = true
        let lat = mapView!.userLocation.coordinate.latitude
        let lon = mapView!.userLocation.coordinate.longitude
        let loc = CLLocation(latitude: lat, longitude: lon)
        // Set the delegate property of our map view to self after instantiating it.
        loc.coordinate.latitude
        mapView!.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            // TODO: alert
        }
        else {
            imagePickerController!.sourceType = UIImagePickerControllerSourceType.Camera
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func showCamera() {
        self.presentViewController(imagePickerController!, animated: true, completion:{() -> Void in })
    }
    
    func revGeocode(location: CLLocation!) {
        let gcrev = CLGeocoder()
        let block: CLGeocodeCompletionHandler = ({(placemarks: [AnyObject]!, error: NSError!) -> Void in
            let revMark: CLPlacemark = placemarks[0] as! CLPlacemark
        })
        
        gcrev.reverseGeocodeLocation(location, completionHandler: block)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if newLocation.coordinate.latitude != oldLocation.coordinate.latitude {
            self.revGeocode(newLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //        self.revGeocode(manager.location)
        let ellipse1 = MyAnnotation(location: CLLocationCoordinate2D(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude),
            title: "Hello world!", subtitle: "Welcome to The Ellipse.", type: AnnotationType.Me)
        
        // Add marker `ellipse` to the map
        self.mapView!.removeAnnotations(self.mapView!.annotations)
        self.mapView!.addAnnotation(ellipse1)
        self.mapView!.setCenterCoordinate(CLLocationCoordinate2D(latitude:manager.location.coordinate.latitude, longitude:manager.location.coordinate.longitude), zoomLevel: 15, animated:false)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    
    func mapView(mapView: MGLMapView!, annotationCanShowCallout annotation: MGLAnnotation!) -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if explained == true {
            self.presentViewController(imagePickerController!, animated: true, completion:{() -> Void in })
        }
        else {
            self.explainerPopUp.hidden = false
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let chosenImage: UIImage = editingInfo[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.imageView.image = chosenImage;
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosenImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(chosenImage, 1.0)
        self.imageView.image = chosenImage;
        
        var parameters = [
            "uploader_id": UIDevice.currentDevice().identifierForVendor.UUIDString,
        ]
        
        let urlRequest = urlRequestWithComponents("http://requestb.in/19x6fnq1", parameters: parameters, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, urlRequest.1)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .response { (request, response, _, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("ERROR \(error)")
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
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
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
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




public enum Router:URLRequestConvertible {
    case Upload(fieldName: String, fileName: String, mimeType: String, fileContents: NSData, boundaryConstant:String);
    
    var method: Alamofire.Method {
        switch self {
        case Upload:
            return .POST
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case Upload:
            return "/testupload.php"
        default:
            return "/"
        }
    }
    
    public var URLRequest: NSURLRequest {
        var URL: NSURL = NSURL(string: "http://requestb.in/18qq1gn1")!
        var mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .Upload(let fieldName, let fileName, let mimeType, let fileContents, let boundaryConstant):
            let contentType = "multipart/form-data; boundary=" + boundaryConstant
            var error: NSError?
            let boundaryStart = "--\(boundaryConstant)\r\n"
            let boundaryEnd = "--\(boundaryConstant)--\r\n"
            let contentDispositionString = "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
            let contentTypeString = "Content-Type: \(mimeType)\r\n\r\n"
            
            // Prepare the HTTPBody for the request.
            let requestBodyData : NSMutableData = NSMutableData()
            requestBodyData.appendData(boundaryStart.dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(contentTypeString.dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(fileContents)
            requestBodyData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            requestBodyData.appendData(boundaryEnd.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            mutableURLRequest.HTTPBody = requestBodyData
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0
            
        default:
            return mutableURLRequest
        }
    }
}

class PopUp: UIView {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    
    func setUp() {
        self.layer.cornerRadius = 10.0
        self.gotItButton.layer.cornerRadius = 10.0
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
            
            
        })
    }
}


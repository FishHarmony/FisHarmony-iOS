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

/**
"ship_name" : null,
"id" : 6,
"notes" : "dasdada",
"image" : "https:\/\/fisharmony.blob.core.windows.net\/image\/thumb\/55163dd9746ba7feb05e81c0d210dc47.jpg",
"geolocation" : {
"longitude" : "-118.195566",
"latitude" : "33.767288"
}
**/

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MGLMapViewDelegate {
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explainerPopUp: PopUp!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    private var imagePickerController: UIImagePickerController?
    private var locationManager: CLLocationManager = CLLocationManager()
    private var direction: CLLocationDirection = 0.0
    private var mapView: MGLMapView?
    private var explained: Bool = false
    private var locatedMe: Bool = false
    private var zoomNumber: Double = 16
    private var location: CLLocation?
    private var zoomDirection: Int = -1
    
    func mapView(mapView: MGLMapView!, symbolNameForAnnotation annotation: MGLAnnotation!) -> String! {
        return (annotation as! MyAnnotation).picture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewAsLoading(true)
        self.explainerPopUp.hidden = true
        self.progressView.layer.cornerRadius = 5.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showCamera", name: "yes", object: nil)
        self.mapView = MGLMapView(frame: self.view.frame, accessToken: "pk.eyJ1Ijoid2hpdG5leW1hcnRpbmZlbGl4ZGFubnkiLCJhIjoiOTZkNGNlNDYwZmZmMmJlYmE1YWU0M2VlZTg5NzdjZDkifQ.0WNO3P6yhLQXppQs5-aGEA")
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView!.delegate = self
        let gr = UITapGestureRecognizer(target: self, action: "zoom:")
        gr.numberOfTapsRequired = 2
        self.mapView?.addGestureRecognizer(gr)
        self.mapView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.view.addSubview(self.mapView!)
        
        // Do any additional setup after loading the view, typically from a nib.
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        imagePickerController!.allowsEditing = false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            
        }
        else {
            imagePickerController!.sourceType = UIImagePickerControllerSourceType.Camera
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setViewAsLoading(should: Bool) {
        self.progressView.hidden = !should
        self.cameraButton.enabled = !should
        self.mapView?.userInteractionEnabled = !should
        self.view.bringSubviewToFront(self.progressView)
    }
    
    func zoom(sender: AnyObject) {
        var center = mapView?.centerCoordinate
        setViewAsLoading(true)
        let z = zoomNumber
        if z <= 5 { //z = 0
            zoomDirection = 1
            zoomNumber++
        }
        else if z <= 16 { // z = 1-16 -> 0-15
            if zoomDirection == -1 {
                zoomNumber--
            }
            else if zoomDirection == 1 {
                zoomNumber++
            }
            if zoomNumber == 16 {
                zoomDirection = -1
            }
        }

        mapView?.setCenterCoordinate(center!, zoomLevel: zoomNumber, animated: true)
        setViewAsLoading(false)
    }
    
    func findShips() {
        setViewAsLoading(true)
        var request: Request = Alamofire.request(Method.GET, "https://fisharmony.herokuapp.com/api/reports/search.json")
        request.responseJSON() {
            (_, _, data, err) in
            if err == nil {
                
                var json = JSON(data!)
                var ships: NSMutableArray = NSMutableArray()
                for var i = 0; i<json.count; i++ {
                    let ship = Ship(json: json[i])
                    ships.addObject(ship)
                    if (ship.hasLocation) {
                        var annotationType: AnnotationType = AnnotationType.OtherShip
                        if ship.hasName == false {
                            annotationType = AnnotationType.IllegalActivity
                        }
                        let ellipse = MyAnnotation(location: CLLocationCoordinate2D(latitude: self.locationManager.location.coordinate.latitude, longitude: self.locationManager.location.coordinate.longitude),
                            title: ship.name!, subtitle: ship.notes!, type: annotationType)
                        
                        // Add marker `ellipse` to the map
                        
                        self.mapView!.addAnnotation(ellipse)
                    }
                    else {
                        // error
                    }
                }
            }
            else {
                
            }
        }
        
    }
    
    func showCamera() {
        setViewAsLoading(false)
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
        //        setViewAsLoading(false)
        if newLocation.coordinate.latitude != oldLocation.coordinate.latitude {
            location = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            self.revGeocode(newLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //        self.revGeocode(manager.location)
        //        setViewAsLoading(false)
        location = manager.location
        if locatedMe == false {
            let ellipse1 = MyAnnotation(location: CLLocationCoordinate2D(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude),
                title: "That's you!", subtitle: "", type: AnnotationType.Me)
            
            // Add marker `ellipse` to the map
            self.mapView!.addAnnotation(ellipse1)
            self.mapView!.setCenterCoordinate(CLLocationCoordinate2D(latitude:manager.location.coordinate.latitude, longitude:manager.location.coordinate.longitude), zoomLevel: zoomNumber, animated:false)
            manager.stopUpdatingLocation()
            self.locationManager.stopUpdatingLocation()
            locatedMe = true
        }
        else {
            manager.stopUpdatingLocation()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        setViewAsLoading(false)
        
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        setViewAsLoading(false)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        setViewAsLoading(false)
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
            self.showCamera()
        }
        else {
            explained = true
            explainerPopUp.setUp("See sometthing fishy? Take a picture to report illegal activity. When you get back to shore, open this app again. That's it... Really.", button: "Got It")
            self.explainerPopUp.hidden = false
            self.view.bringSubviewToFront(self.explainerPopUp)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let chosenImage: UIImage = editingInfo[UIImagePickerControllerOriginalImage] as! UIImage
        
        //        self.imageView.image = chosenImage;
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let chosenImage: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(chosenImage, 1.0)
        //        self.imageView.image = chosenImage;
        var parameters = [
            "uploader_id": UIDevice.currentDevice().identifierForVendor.UUIDString
        ]
        
        let urlRequest = urlRequestWithComponents("https://fisharmony.herokuapp.com/api/reports/", parameters: parameters, imageData: imageData)
        
        Alamofire.upload(urlRequest.0, urlRequest.1).progress
            {
                (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            }.response
            {
                (request, response, _, error) in
                println("REQUEST \(request)")
                println("RESPONSE \(response)")
                println("ERROR \(error)")
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func mapViewDidFailLoadingMap(mapView: MGLMapView!, withError error: NSError!) {
        setViewAsLoading(false)
    }
    
    func mapViewDidFinishLoadingMap(mapView: MGLMapView!) {
        setViewAsLoading(false)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MGLMapView!, fullyRendered: Bool) {
        self.cameraButton.enabled = true
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
        var URL: NSURL = NSURL(string: "https://fisharmony.herokuapp.com/api/reports/")!
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




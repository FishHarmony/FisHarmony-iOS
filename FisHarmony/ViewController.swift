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
    private var zoomNumber: Double = 15
    
    func mapView(mapView: MGLMapView!, symbolNameForAnnotation annotation: MGLAnnotation!) -> String! {
        switch (annotation as! MyAnnotation).type! {
        case .Me:
            return "default_marker"
        case .OtherShip:
            return "ferry-11"
        case .InjuredMammel:
            return "hospital-11"
        case .IllegalActivity:
            return "secondary_marker"
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.explainerPopUp.hidden = true
        setViewAsLoading(true)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.findShips()
        })
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
            self.mapView = MGLMapView(frame: self.view.frame, accessToken: "pk.eyJ1Ijoid2hpdG5leW1hcnRpbmZlbGl4ZGFubnkiLCJhIjoiOTZkNGNlNDYwZmZmMmJlYmE1YWU0M2VlZTg5NzdjZDkifQ.0WNO3P6yhLQXppQs5-aGEA")
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            self.mapView!.delegate = self
            let gr = UITapGestureRecognizer(target: self, action: "zoom")
            gr.numberOfTapsRequired = 2
            self.mapView?.addGestureRecognizer(gr)
            self.mapView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            // set the map's center coordinate
            // long beach: 33.7717 N, 118.1934 W
            self.view.addSubview(self.mapView!)
        })
        
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
    }
    
    func zoom() {
        // 30 22.5 15
        setViewAsLoading(true)
        switch zoomNumber {
        case 15:
            mapView?.zoomLevel = 5
            break
        case 7.5:
            mapView?.zoomLevel = 15
            break
        case 5:
            mapView?.zoomLevel = 7.5
            break
        default:
            break
        }
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
        setViewAsLoading(false)
        if newLocation.coordinate.latitude != oldLocation.coordinate.latitude {
            self.revGeocode(newLocation)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //        self.revGeocode(manager.location)
        setViewAsLoading(true)
        if locatedMe == false {
            let ellipse1 = MyAnnotation(location: CLLocationCoordinate2D(latitude: manager.location.coordinate.latitude, longitude: manager.location.coordinate.longitude),
                title: "That's you!", subtitle: "", type: AnnotationType.Me)
            
            // Add marker `ellipse` to the map
            self.mapView!.addAnnotation(ellipse1)
            self.mapView!.setCenterCoordinate(CLLocationCoordinate2D(latitude:manager.location.coordinate.latitude, longitude:manager.location.coordinate.longitude), zoomLevel: zoomNumber, animated:false)
            manager.stopUpdatingLocation()
            locatedMe = true
        }
        else {
            manager.stopUpdatingLocation()
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
            "uploader_id": UIDevice.currentDevice().identifierForVendor.UUIDString,
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

class PopUp: UIView {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    
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
        })
    }
}

private class Ship {
    var name: String?
    var id: Int?
    var notes: String?
    var image: UIImage?
    var lat: String?
    var lon: String?
    var hasName: Bool = true
    var hasNotes: Bool = true
    var hasLocation: Bool = true
    
    init(json: JSON) {
        name = json["ship_name"].string
        if name == nil {
            hasName = false
            name = "No Name On Record"
        }
        id = json["id"].intValue
        notes = json["notes"].string
        if notes == nil {
            hasNotes = false
            notes = ""
        }
        //        image = json["image"].string
        image = nil
        lat = json["geolocation"]["latitude"].string
        lon = json["geolocation"]["longitude"].string
        if lon == nil || lat == nil {
            hasLocation = false
        }
    }
    
}


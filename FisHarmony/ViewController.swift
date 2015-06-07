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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    private var imagePickerController: UIImagePickerController?
    private var locationManager: CLLocationManager?
    private var direction: CLLocationDirection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        self.presentViewController(imagePickerController!, animated: true, completion:{() -> Void in })
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
            "uploader_id": "abc",
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
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
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


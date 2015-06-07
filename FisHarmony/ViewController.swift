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
        
        self.imageView.image = chosenImage;
//        var imageData = UIImageJPEGRepresentation(chosenImage, 0.1)
//        let bin = "http://requestb.in/1adk4gc1"
//        let encoding = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        
        
        
        let fileName = "illegalActivity.jpg"
        
        Photo.upload(chosenImage, filename: fileName).progress {
            (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                println(totalBytesWritten)
            }.responseJSON {
                (request, response, JSON, error) in
                println(JSON)
            }
        
//            Method.POST, "\(bin)/node/\(UIDevice.currentDevice().identifierForVendor.UUIDString)/attach_file", parameters: nil, constructingBodyWithBlock:
//            {
//                (formData) -> Void in
//                
//                formData.appendPartWithFileData(imageData, name: "files[field_mobileinfo_image]", fileName: "field_mobileinfo_image", mimeType: "image/jpeg")
//                formData.appendPartWithFormData("field_mobileinfo_image".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), name: "field_name")
//        })
        
        //        let str = NSString(data: imageData, encoding: UInt.allZeros)
        //        let str = String(stringInterpolationSegment: encoding)
        //        let apiRequest:Request = request(Method.POST, bin, parameters: params, encoding: ParameterEncoding.JSON)
        
        //        Alamofire.request(Alamofire.Method.POST, bin, parameters: params, encoding: nil)
        //        NSLog("All Zeros: \(imageData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.allZeros).description)")
        //        NSLog("64 char line length: \(imageData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength).description)")
        //        NSLog("76 char line length: \(imageData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding76CharacterLineLength).description)")
        //        NSLog("End line with carriage return: \(imageData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn).description)")
        //        NSLog("End line with line feed: \(imageData.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed).description)")
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
    }
    
}

class Photo {
    class func upload(image: UIImage, filename: String) -> Request {
        let bin = "http://requestb.in/1fmv23g1"
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: bin)!)
        let mimeType = "image/jpeg"
        let name = "image"
//        var bodyData = "fileName=\(filename)&mimeType=\(mimeType)&name=\(name)"
//        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let boundary = "NET-POST-boundary-\(arc4random())-\(arc4random())"
        request.setValue("multipart/form-data;boundary="+boundary, forHTTPHeaderField: "Content-Type")
        let params: [String: AnyObject] = ["uploader_id" as String: UIDevice.currentDevice().identifierForVendor.UUIDString]

        let parameters = NSMutableData()
        for s in
            ["\r\n--\(boundary)\r\n", "Content-Disposition: form-data; name=\"\(name)\";" + " filename=\"\(filename)\"\r\n", "Content-Type: \(mimeType)\r\n\r\n"]
        {
                parameters.appendData(s.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        parameters.appendData(UIImageJPEGRepresentation(image, 1))
        parameters.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        return Alamofire.upload(request, parameters)
    }
}


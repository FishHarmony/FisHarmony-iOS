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

// MARK: Delegate Declaration
@objc
protocol ViewControllerDelegate {
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}



class ViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate, MenuViewControllerActionDelegate {
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var explainerPopUp: PopUp!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    private var locationManager: CLLocationManager = CLLocationManager()
    private var direction: CLLocationDirection = 0.0
    private var mapView: MGLMapView?
    private var zoomNumber: Double = 15
    private var location: CLLocation?
    private var selectedIndex: Int?
    private var zoomDirection: Int = -1
    var delegate: ViewControllerDelegate?
    private var waitingToSegue: Bool = false
    private var requestedLocationPlacement: Bool = false
    private var annotation: MyAnnotation?
    
    func mapView(mapView: MGLMapView!, symbolNameForAnnotation annotation: MGLAnnotation!) -> String! {
        return (annotation as! MyAnnotation).picture()
    }
    
    func mapView(mapView: MGLMapView!, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation!) -> UIView! {
        var button: UIButton = UIButton.buttonWithType(UIButtonType.InfoLight) as! UIButton
        return button
    }
    
    func mapView(mapView: MGLMapView!, annotation: MGLAnnotation!, calloutAccessoryControlTapped control: UIControl!) {
        self.annotation = annotation as? MyAnnotation
        self.performSegueWithIdentifier("showDetails", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewAsLoading(true)
        self.explainerPopUp.setUp("Take a picture to report illegal activity. This is completely anonymous. When you have signal, we'll send the report for you. That's it... Really", button: "Got It")
        self.explainerPopUp.hidden = true
        self.progressView.layer.cornerRadius = 5.0
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showCamera", name: "yes", object: nil)
        self.mapView = MGLMapView(frame: self.view.frame, accessToken: "pk.eyJ1Ijoid2hpdG5leW1hcnRpbmZlbGl4ZGFubnkiLCJhIjoiOTZkNGNlNDYwZmZmMmJlYmE1YWU0M2VlZTg5NzdjZDkifQ.0WNO3P6yhLQXppQs5-aGEA")
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.mapView!.delegate = self
        let gr = UITapGestureRecognizer(target: self, action: "zoom:")
        gr.numberOfTapsRequired = 2
        self.mapView?.addGestureRecognizer(gr)
        self.mapView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.mapView?.showsUserLocation = true
        self.view.addSubview(self.mapView!)
        self.refresh(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.delegate = self
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
        else if z <= 15 { // z = 1-16 -> 0-15
            if zoomDirection == -1 {
                zoomNumber--
            }
            else if zoomDirection == 1 {
                zoomNumber++
            }
            if zoomNumber == 15 {
                zoomDirection = -1
            }
        }
        
        mapView?.setCenterCoordinate(mapView!.userLocation.coordinate, zoomLevel: zoomNumber, animated: true)
        setViewAsLoading(false)
    }
    
    func mapView(mapView: MGLMapView!, didUpdateUserLocation userLocation: MGLUserLocation!) {
        if requestedLocationPlacement {
            location = mapView.userLocation.location
        mapView?.setCenterCoordinate(mapView!.userLocation.coordinate, zoomLevel: 15, animated: true)
            requestedLocationPlacement = false
        }
        NSNotificationCenter.defaultCenter().postNotificationName("gotLocation", object: nil)
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
                    if (ship.location != nil) {
                        var annotationType: Int = typeDictionary[ship.category!]!

                        let ellipse = MyAnnotation(location: ship.location!,
                            title: ship.name!, subtitle: ship.notes!, type: annotationType, image: ship.image)
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
            self.mapView?.setCenterCoordinate(self.location!.coordinate, zoomLevel: self.zoomNumber, animated: true)
            self.setViewAsLoading(false)
        }
        
    }
    
    func showCamera() {
        setViewAsLoading(false)
        delegate?.toggleRightPanel?()

//        self.presentViewController(imagePickerController!, animated: true, completion:{() -> Void in })
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
            location = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        location = locations[0] as? CLLocation
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
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if UserDefaults.defaults.boolForKey(UserDefaults.types.explainationGiven) == true {
            self.showCamera()
        }
        else {
            self.explainerPopUp.hidden = false
            self.view.bringSubviewToFront(self.explainerPopUp)
            UserDefaults.defaults.setBool(true, forKey: UserDefaults.types.explainationGiven)
        }
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
    
    func selectedMenuOption(optionIndex: Int) {
        waitingToSegue = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotLocation", name: "gotLocation", object: nil)
        requestedLocationPlacement = true
        selectedIndex = optionIndex
        self.setViewAsLoading(true)
    }
    
    internal func gotLocation() {
        if waitingToSegue {
            waitingToSegue = false
        self.performSegueWithIdentifier("makeReport", sender: self)
            self.setViewAsLoading(false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "makeReport" {
            (segue.destinationViewController as! ReportViewController).location = location
            (segue.destinationViewController as! ReportViewController).type = reverseTypeDictionary[selectedIndex!]
            (segue.destinationViewController as! ReportViewController).locationManager = locationManager
        }
        else if segue.identifier == "showDetails" {
            (segue.destinationViewController as! InfoViewController).notes = annotation?.subtitle
            (segue.destinationViewController as! InfoViewController).shipName = annotation?.title
            (segue.destinationViewController as! InfoViewController).latLon = annotation?.coordinate
            (segue.destinationViewController as! InfoViewController).image = annotation?.image
            (segue.destinationViewController as! InfoViewController).type = reverseTypeDictionary[annotation!.type]
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
        requestedLocationPlacement = true
        findShips()
    }
}



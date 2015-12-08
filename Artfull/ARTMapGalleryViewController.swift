//
//  ARTMapGalleryViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBook
import Parse


class ARTMapGalleryViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userTrackingBarButton: MKUserTrackingBarButtonItem!
    
    var locationText = ""
    var locationDetailText = ""
    var galleryLocation: CLLocationCoordinate2D!
    
    let locationManager = CLLocationManager ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let query = PFQuery(className: "Galleries")
        
        // Add conditions
        query.whereKeyExists("Images")
        query.whereKeyExists("Gallery_Name")
        query.whereKeyExists("Neighborhood")
        query.whereKeyExists("Category")
        
        
        // Order the results
        query.orderByAscending("createdAt")
        
        // Cache results
        query.cachePolicy = .CacheElseNetwork
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil
            {
                //Sucess fetching object
                print(objects?.count)
                if let objects = objects where objects.count > 0
                {
                    // objects is not nil
                    for object in objects
                    {
                        print("object[Location] = \(object["Location"])")
                        if  let newLocationText = object["Gallery_Name"] as? String,
                            let newLocationDetailText = object["Neighborhood"] as? String,
                            let newGalleryLocation = object["Location"] as? PFGeoPoint
                        {
                            
                            let latitude: CLLocationDegrees = newGalleryLocation.latitude
                            let longitude: CLLocationDegrees = newGalleryLocation.longitude
                            
                            let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            
                            let gallery = GalleryAnnotation(
                                title: newLocationText,
                                locationName: newLocationDetailText,
                                coordinate: location, galleryObject: object)
                            
                            self.mapView.addAnnotation(gallery)
                        }
                    }
                }
                else
                {
                    //objects is nil
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    func queueUpDataAndPopulatePins () {
        
        let query = PFQuery(className: "Galleries")
        
        // Add conditions
        query.whereKeyExists("Location")
        query.whereKeyExists("Gallery_Name")
        query.whereKeyExists("Neighborhood")
        
        // Order the results
        query.orderByAscending("createdAt")
        
        // Cache results
        query.cachePolicy = .CacheElseNetwork
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil { //Sucess fetching object
                print(objects?.count)
                if let objects = objects where objects.count > 0 {  // objects is not nil
                    for object in objects{
                        if let gallery = GalleryAnnotation(galleryObject: object){
                            self.mapView.addAnnotation(gallery)
                        }
                    }
                }
                else {
                    //objects is nil
                }
            }
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Current location: \(location)")
            
            if userTrackingBarButton.mapView == nil
            {
                userTrackingBarButton.mapView = mapView
            }
            
            let userCoordinate = location.coordinate
            let mySpan = MKCoordinateSpanMake(0.08, 0.08)
            let myRegion = MKCoordinateRegionMake(userCoordinate, mySpan)
            mapView.setRegion(myRegion, animated: true)
            mapView.showsUserLocation = true
            
            locationManager.stopUpdatingLocation()
            
        } else {
            // handle error
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
    
    @IBAction func resetMapCurrentLocation(sender: AnyObject) {
        mapView.userTrackingMode = MKUserTrackingMode.Follow
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            print(view.annotation!.title)
            print(view.annotation!.subtitle)
            
            if let galleryAnnotation = view.annotation as? GalleryAnnotation{
                let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("GalleryDetailTable") as! ARTGalleryDetailTableViewController
                destinationVC.galleryObj = galleryAnnotation.galleryObject
                navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
        }
        
        let button = UIButton(type: .DetailDisclosure)
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
        
    }
    
}


//
//  ARTGalleryDetailTableViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import InstagramKit
import Alamofire
import AlamofireImage
import Parse
import MapKit
import CoreLocation
import UberRides


class ARTGalleryDetailTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // Declarations
    var instagramPictureURLs = [NSURL]()
    var locationText = ""
    var locationDetailText = ""
    var galleryLocation: CLLocationCoordinate2D!
    var streetName = ""
    var state = ""
    var postalCode = ""
    var phoneNumber = ""
    var galleryName = ""
    var userLocation : CLLocationCoordinate2D!
    
    // Outlets
    
    @IBOutlet weak var galleryDetailStreetName: UITextField!
    @IBOutlet weak var galleryDetailOpeningHours: UITextField!
    @IBOutlet weak var galleryDetailOwner: UITextField!
    @IBOutlet weak var galleryDetailDescription: UITextView!
    @IBOutlet weak var GalleryDetailImage: UIImageView!
    @IBOutlet weak var GalleryDetailInstagramCollectionView: UICollectionView!
    @IBOutlet weak var GalleryDetailPhoneNumber: UITextField!
    @IBOutlet weak var GalleryDetailWebsite: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    /* Variables */
    var galleryObj = PFObject(className: "Galleries")
    var galleryArray = NSMutableArray()
    var instagramCellHeight: CGFloat = 0
    
    let query = PFQuery(className: "Galleries")
    var testManager = CLLocationManager()
    
    /* Function View Did Load */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        testManager.delegate = self
        testManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        testManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = false
        
        if let newLocationText = galleryObj["Gallery_Name"] as? String,
            let newLocationDetailText = galleryObj["Neighborhood"] as? String,
            let newGalleryLocation = galleryObj["Location"] as? PFGeoPoint {
                
                print("What is this, \(newGalleryLocation)")
                
                let latitude: CLLocationDegrees = newGalleryLocation.latitude
                let longitude: CLLocationDegrees = newGalleryLocation.longitude
                let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                galleryLocation = location
                
                print("What is this latitude and longitude: \(latitude) \(longitude)")
                
                let galleryTest = GalleryAnnotation(title: newLocationText, locationName: newLocationDetailText, coordinate: location, galleryObject: galleryObj)
                
//                let gallery = GalleryAnnotation(
//                    title: newLocationText,
//                    locationName: newLocationDetailText,
//                    coordinate: location)
                
                mapView.addAnnotation(galleryTest)
                mapView.setCenterCoordinate(location, animated: true)
                
        }
        
        testManager.stopUpdatingLocation()

        
        // Customize Navigation Bar
        navigationController?.navigationBar.tintColor? = .blackColor()
        self.title = "\(galleryObj["Gallery_Name"]!)"
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Instagram Collection view
        GalleryDetailInstagramCollectionView.delegate = self
        GalleryDetailInstagramCollectionView.dataSource = self

        
        // Get the data from Gallery List
        testManager.delegate = self
        testManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        testManager.requestWhenInUseAuthorization()
        
        mapView.showsUserLocation = false
        
        if let newLocationText = galleryObj["Gallery_Name"] as? String,
            let newLocationDetailText = galleryObj["Neighborhood"] as? String,
            let newGalleryLocation = galleryObj["Location"] as? PFGeoPoint {
                
                print("What is this, \(newGalleryLocation)")
                
                let latitude: CLLocationDegrees = newGalleryLocation.latitude
                let longitude: CLLocationDegrees = newGalleryLocation.longitude
                let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                galleryLocation = location
                
                print("What is this latitude and longitude: \(latitude) \(longitude)")
                
                let gallery = GalleryAnnotation(
                    title: newLocationText,
                    locationName: newLocationDetailText,
                    coordinate: location, galleryObject: galleryObj)
                
                mapView.addAnnotation(gallery)
                mapView.setCenterCoordinate(location, animated: true)
                
        }
        testManager.stopUpdatingLocation()
        
        
        //load Instagram images
        
        let engine = InstagramEngine.sharedEngine()
        
        if let galleryID = galleryObj["Gallery_Instagram_ID"] as? String {
            
            engine.getMediaForUser(galleryID, withSuccess: { (allMedia:[AnyObject]!, paginationInfo: InstagramPaginationInfo!) -> Void in
                
                for media in allMedia
                {
                    print(media.standardResolutionImageURL)
                    
                    self.instagramPictureURLs.append(media.standardResolutionImageURL)
                    
                    if(self.instagramPictureURLs.count == 8)
                    {
                        self.GalleryDetailInstagramCollectionView.reloadData()
                        break;
                    }
                    
                }
                })
                { (error:NSError!, serverStatusCode:Int) -> Void in
                    
                    print("I've failed!")
            }}
        
        // Data from Gallery
        if galleryObj["Description"] != nil {
            self.galleryDetailDescription.text      = "\(galleryObj["Description"]!)"
        } else {  self.galleryDetailDescription.text = ""  }
        
        if galleryObj["Opening_hours_string"] != nil {
            self.galleryDetailOpeningHours.text     = "Open \(galleryObj["Opening_hours_string"]!)"
        } else {  self.galleryDetailOpeningHours.text = ""  }
        
        if galleryObj["Street_name"] != nil {
            self.galleryDetailStreetName.text       = "\(galleryObj["Street_name"]!)"
        } else {  self.galleryDetailStreetName.text = ""  }
        
        if galleryObj["Owner_Name"] != nil {
            self.galleryDetailOwner.text            = "Managed by \(galleryObj["Owner_Name"]!)"
        } else {  self.galleryDetailOwner.text = ""  }
        
        if galleryObj["Phone_Number"] != nil {
            self.GalleryDetailPhoneNumber.text      = "\(galleryObj["Phone_Number"]!)"
        } else {  self.GalleryDetailPhoneNumber.text = ""  }
        
        if galleryObj["Gallery_Website"] != nil {
            self.GalleryDetailWebsite.text  = "\(galleryObj["Gallery_Website"]!)"
        } else {  self.GalleryDetailWebsite.text = ""  }
        
        
        // GET GALLERY'S IMAGE
        let imageFile = galleryObj["Images"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.GalleryDetailImage.image = UIImage(data:imageData)
                } } }
        
        
    }
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 8
    }
    
    // Instagram
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return instagramPictureURLs.count
    }
    
    // Dynamic heights modification
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) ->  CGFloat
    {
        // Instagram
        if indexPath.row == 0 {
            return 218
        }
        if indexPath.row == 1 {
            return 141
        }
        if indexPath.row == 2 {
            return 40
        }
        if indexPath.row == 3 {
            return 40
        }
        if indexPath.row == 4 {
            return 138
        }
        if indexPath.row == 5 && instagramPictureURLs.count > 0 {
            return 239
        }
        if indexPath.row == 6 {
            return 0
        }
        if indexPath.row == 7 {
            return 0
        }
        return 239
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print ("We're getting called")
        
    }
    
    // MARK: - Collection view
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("instagramCell", forIndexPath: indexPath) as! InstagramCustomCell
        
        cell.imageURL = instagramPictureURLs[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath)
        {
            let cell = cell as! InstagramCustomCell
            let selectedImage = cell.instagramImage.image
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let modalVC = storyboard.instantiateViewControllerWithIdentifier("instagramModalVC") as! ARTLargeInstagramImage
            modalVC.instagramImage = selectedImage
            (presentViewController(modalVC, animated: true, completion: nil))
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Update called?")
        if let location = locations.last {
            
            let mySpan = MKCoordinateSpanMake(0.007, 0.007)
            let myRegion = MKCoordinateRegionMake(galleryLocation, mySpan)
            mapView.setRegion(myRegion, animated: true)
            userLocation = (manager.location?.coordinate)!
            
            testManager.stopUpdatingLocation()
            
        } else {
            print("this isn't happening")
            // handle error
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        testManager.startUpdatingLocation()
    }
    
    @IBAction func addressButtonTapped(sender: AnyObject) {
        
        print(galleryLocation)
        
        let address = [""]
        
        var latitude:CLLocationDegrees = galleryLocation.latitude
        var longitude:CLLocationDegrees = galleryLocation.longitude
        
        let placeMark = MKPlacemark(coordinate: galleryLocation, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
        
        
        
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        
        if let streetName = "\(galleryObj["Street_name"]!)" as String?,
            let postalCode = "\(galleryObj["Postal_code"]!)" as String?,
            let state = "\(galleryObj["State"]!)" as String?,
            let galleryName = "\(galleryObj["Gallery_Name"])" as String? {
                
                let activityItem:String! = "\(galleryName)\n\(streetName), \(state), \(postalCode)"
                
                let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
                
                self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func callButtonTapped(sender: AnyObject) {
        
        if let phoneNumber = "\(galleryObj["Phone_Number"]!)" as String? {
            
            if let url = NSURL(string: "tel://\(phoneNumber)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    
    
    //    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    //
    //        if indexPath.row == 0 {
    //            return nil
    //        }
    //        if indexPath.row == 1 {
    //
    //        }
    //        if indexPath.row == 2 {
    //
    //        }
    //        if indexPath.row == 3 {
    //
    //        }
    //        if indexPath.row == 4 {
    //            return nil
    //        }
    //        if indexPath.row == 5 {
    //
    //        }
    //        if indexPath.row == 6 {
    //
    //        }
    //        if indexPath.row == 7 {
    //            return nil
    //        } else {
    //        return nil
    //        }
    //    }
    
    @IBAction func visitButtonTapped(sender: AnyObject) {
        
        if let galleryWebsite = "\(galleryObj["Gallery_Website"]!)" as String? {
            
            if let url = NSURL(string: "http://www.\(galleryWebsite)") {
                UIApplication.sharedApplication().openURL(url)
            }
            
        }
    }
    
    
//    @IBAction func uberButtonTapped(sender: AnyObject) {
//        
//        if let newGalleryLocation = galleryObj["Location"] as? PFGeoPoint {
//            
//            print("What is this, \(newGalleryLocation)")
//            
//            let newLocationText = galleryObj["Gallery_Name"] as? String
//            let destinationLatitude: CLLocationDegrees = newGalleryLocation.latitude
//            let destinationLongitude: CLLocationDegrees = newGalleryLocation.longitude
//            
//            var uberHooks = "uber://?client_id=gGwcouSmBOM_XouAiUHox3soE3Uhq8WB&action=setPickup&pickup[latitude]=\(userLocation.latitude)&pickup[longitude]=\(userLocation.longitude)&pickup[nickname]=CurrentLocation[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103&dropoff[latitude]=\(destinationLatitude)&dropoff[longitude]=\(destinationLongitude)&dropoff[nickname]=\(newLocationText)&dropoff[formatted_address]=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d"
//            
//            var uberUrl = NSURL(string: uberHooks)
//            if UIApplication.sharedApplication().canOpenURL(uberUrl!)
//            {
//                UIApplication.sharedApplication().openURL(uberUrl!)
//                
//            } else {
//                //redirect to safari because the user doesn't have Uber
//                print("App not installed")
//                UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/uber/id368677368?mt=8")!)
//                
//            }
    
            
        }
        
        



//
//  MainPageViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import CoreLocation
import Concorde
import Photos

class MainPageViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    //////////////////////////// VARIABLES DECLARATIONS
    
    /* Declare Table View */
    @IBOutlet weak var mainPageTableView:   UITableView!
    
    /* Variables for Parse */
    var imageFiles                          = [PFFile]()
    var galleryArray                        = NSMutableArray()
    
    /* Variables to calculate distance between the User and the Galleries */
    var locationManager:                    CLLocationManager!
    var galleryDistance                     = [String]()
    var galleryDistanceString               = [String]()
    var latitude:                           CLLocationDegrees = 0
    var longitude:                          CLLocationDegrees = 0
    
    //////////////////////////// MAIN FUNCTIONS
    
    /* Function View Did Load */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Navigation bar
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.backBarButtonItem?.title = ""
        
        // Title and search button
        let button = UIButton()
        button.frame = CGRectMake(0, 0, 100, 40) as CGRect
        button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        button.setTitle("Galleries", forState: UIControlState.Normal)
        button.titleLabel!.font = UIFont(name: "Avenir Next", size: 16)
       // button.addTarget(self, action: Selector("clickOnButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.titleView = button
        
        // Calling location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Query the gallerie list from Parse
        queryGalleryList()
    }
    
    /* Function Query Gallery List */
    func queryGalleryList()
    {
        galleryArray.removeAllObjects()
        
        let query = PFQuery(className: "Galleries")
        query.whereKeyExists("Gallery_Name")
        query.whereKeyExists("Images")
        query.whereKeyExists("Location")
        
        // Ordering
        query.orderByAscending("Gallery_Name")
        
        // Query block
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                //Sucess fetching object
                print(objects?.count)
                
                if let objects = objects  {
                    for object in objects {
                        self.galleryArray.addObject(object)
                    } }
                self.mainPageTableView.reloadData()
                
            } else {
                SCLAlertView().showNotice("Oopss", subTitle: error!.localizedDescription)
                
            } }
    }
    
    /* Function Location Manager */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location:CLLocationCoordinate2D = manager.location!.coordinate
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
    
    //////////////////////////// TABLE/CELLS CONSTRUCTION
    
    /* Table View Definition */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return galleryArray.count
    }
    
    /* Cell Definition */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        if let singleCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as? SingleRowCell {
            
//            let manager = PHImageManager.defaultManager()
//            
//            if singleCell.tag != 0 {
//                manager.cancelImageRequest(PHImageRequestID(singleCell.tag))
//            }
            
            var galleryClass = PFObject(className: "Galleries")
            galleryClass = galleryArray[indexPath.row] as! PFObject
            
            // GET GALLERY'S IMAGE
            let imageFile = galleryClass["Images"] as? PFFile
            
            imageFile?.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        singleCell.swiftgramImageView.image = UIImage(data: imageData)
                    } } }
            
            // GET GALLERY'S TEXT FIELDS
            
            singleCell.galleryNameCell.text                     = "\(galleryClass["Gallery_Name"]!)"
            singleCell.galleryNeighborhoodCell.text             = "\(galleryClass["Neighborhood"]!)"
            
            if let galleryLocation                              = galleryClass["Location"]! as? PFGeoPoint {
                let galleryCLLocation                           = CLLocation(latitude: galleryLocation.latitude, longitude: galleryLocation.longitude)
                let userCLLocation                              = CLLocation(latitude: self.latitude, longitude: self.longitude)
                let distanceMeters                              = userCLLocation.distanceFromLocation(galleryCLLocation)
                let distanceKM                                  = distanceMeters / 1000
                let roundedTwoDigitDistance                     = Double(round(distanceKM * 10) / 10)
                let galleryDistanceString                       = String(format: "%.1f", roundedTwoDigitDistance)
                
                self.galleryDistance.append(galleryDistanceString as String)
                
                singleCell.galleryDistanceCell.text             = galleryDistanceString + " mi"
                
            }else
                
            {
                self.galleryDistance.append("" as String)
                print("No Distance")
            }
            
            return singleCell
        
        }
        
        let normalCell = UITableViewCell()
        return normalCell
        let singleCell: SingleRowCell = tableView.dequeueReusableCellWithIdentifier("singleRowCell") as! SingleRowCell
        
    }
    
    //////////////////////////// NAVIGATION
    
    /* Row Selected => Gallery Detail */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var galleryClass = PFObject(className: "Galleries")
        galleryClass = galleryArray[indexPath.row] as! PFObject
        
        let destinationVC = storyboard?.instantiateViewControllerWithIdentifier("GalleryDetailTable") as! ARTGalleryDetailTableViewController
        destinationVC.galleryObj = galleryClass
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    /* Navigation Button Left Side */
    @IBAction func leftSideButtonTapped(sender: AnyObject)
    {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    /* Navigation Button Right Side */
    @IBAction func rightSideButtonTaped(sender: AnyObject)
    {
        let mapGalleryPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MapGalleryViewController") as! ARTMapGalleryViewController
        self.navigationController?.pushViewController(mapGalleryPageViewController, animated:true)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
//    func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
//        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
//        let imageRef = image.CGImage
//        
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//        
//        // Set the quality level to use when rescaling
//        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
//        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
//        
//        CGContextConcatCTM(context, flipVertical)
//        // Draw into the context; this scales the image
//        CGContextDrawImage(context, newRect, imageRef)
//        
//        let newImageRef = CGBitmapContextCreateImage(context) as CGImage
//        let newImage = UIImage(CGImage: newImageRef)
//        
//        // Get the resized image from the context and a UIImage
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
}





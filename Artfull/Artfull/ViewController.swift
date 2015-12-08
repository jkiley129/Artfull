//
//  ViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import AVKit
import AVFoundation


class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // Variables for video background
    var player      = AVPlayer()
    var movietitle  = "videologin"
    var movietype   = "mp4"
    
    @IBOutlet weak var logoFirstPage:       UIImageView!
    
    // Declaration for the swiping
    @IBOutlet weak var callOutLabel:        UILabel!
    @IBOutlet weak var callOutSubLabel:     UILabel!
    @IBOutlet weak var callOutPageControl:  UIPageControl!
    
    var callOutMsg:[String]                 = []
    var callOutSubMsg:[String]              = []
    var currentMsg:String                   = String()
    var currentSubMsg:String                = String()
    var indexPage                           = 3
    
    // White Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    // FUNC : VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Format the logo with rounded corners
        logoFirstPage.layer.cornerRadius = 5
        
        self.callOutMsg             = ["Discover", "Attend", "Find"]
        self.callOutSubMsg          = ["All the best Art Galleries around you.", "Prestigious exhibitions and opening events. ", "Great affordable Art pieces by local artists."]
        self.currentMsg             = callOutMsg[0]
        self.currentSubMsg          = callOutSubMsg[0]
        self.callOutLabel?.text     = currentMsg
        self.callOutSubLabel?.text  = currentSubMsg
        
        //PageControl Swipe
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        swipeLeft.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.playVideo()
    }
    
    
    @IBAction func callOutPageControlChanged(sender: AnyObject)
    {
        print("callOutPageControlChanged gets called with sender: \(sender)")
        let selectedPage = self.callOutPageControl?.currentPage
        self.callOutLabel?.text = callOutMsg[selectedPage!]
        self.callOutSubLabel?.text = callOutSubMsg[selectedPage!]
    }
    
    //swipe
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        let totalPage = self.callOutMsg.count
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                indexPage--
            case UISwipeGestureRecognizerDirection.Left:
                indexPage++
            default:
                break
            }
            
            indexPage = (indexPage < 0) ? (totalPage - 1):
                indexPage % totalPage
            
            callOutPageControl.currentPage = indexPage
            
            //        NSThread.sleepForTimeInterval(0.1)
            //        indexPage++
            
            self.callOutLabel?.text = callOutMsg[indexPage]
            self.callOutSubLabel?.text = callOutSubMsg[indexPage]
        }
    }
    
    
    // Video Background
    func playVideo() ->Bool
    {
        // Defining the path to the video file - change name here
        let path    = NSBundle.mainBundle().pathForResource(movietitle, ofType:movietype)
        let url     = NSURL.fileURLWithPath(path!)
        player      = AVPlayer(URL: url)
        
        let avPlayerLayer = AVPlayerLayer(player: player)
        
        avPlayerLayer.frame = self.view.bounds
        avPlayerLayer.videoGravity = "AVLayerVideoGravityResizeAspectFill"
        //avPlayerLayer.speed = -0.8
        
        self.view.layer.insertSublayer(avPlayerLayer, atIndex: 0)
        
        player.volume   = 0
        player.play()
        
        // Invoke after player is created and AVPlayerItem is specified
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItemDidReachEnd:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
        
        return true
    }
    
    func playerItemDidReachEnd(notification: NSNotification)
    {
        player.seekToTime(kCMTimeZero)
        player.play()
    }
    
    
    // Connect with Facebook button implementation
    @IBAction func facebookButtonTapped(sender: AnyObject)
    {
        
        // Create Permissions array
        let permissions = ["public_profile","email","user_friends","user_events"]
        
        // Login to Facebook with Permissions
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user:PFUser?, error:NSError?) -> Void in
            
            // If error, display message
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // Error message
                    let userMessage = error!.localizedDescription
                    let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    
                    myAlert.addAction(okAction)
                    
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    return
                } // end of async
            }
            
            // Load facebook user details like user First name, Last name and email address
            self.loadFacebookUserDetails()
        })
    }
    
    
    func loadFacebookUserDetails()
    {
        // Show activity indicator
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Loading"
        spiningActivity.detailsLabelText = "Please wait"
        
        // Define fields we would like to read from Facebook User object
        let requestParameters = ["fields": "id, email, first_name, last_name, name"]
        
        // Send Facebook Graph API Request for /me
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userDetails.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            
            if error != nil {
                
                // Display error message
                spiningActivity.hide(true)
                
                let userMessage = error!.localizedDescription
                let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                PFUser.logOut()
                
                return
            }
            
            // Extract user fields
            let userId:String = result["id"] as! String
            let userEmail:String? = result["email"] as? String
            let userFirstName:String?  = result["first_name"] as? String
            let userLastName:String? = result["last_name"] as? String
            
            // Get Facebook profile picture
            let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
            let profilePictureUrl = NSURL(string: userProfile)
            let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
            
            // Prepare PFUser object
            if(profilePictureData != nil)
            {
                let profileFileObject = PFFile(data:profilePictureData!)
                PFUser.currentUser()?.setObject(profileFileObject!, forKey: "profile_picture")
            }
            
            PFUser.currentUser()?.setObject(userFirstName!, forKey: "first_name")
            PFUser.currentUser()?.setObject(userLastName!, forKey: "last_name")
            
            if let userEmail = userEmail
            {
                PFUser.currentUser()?.email = userEmail
                PFUser.currentUser()?.username = userEmail
            }
            
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                spiningActivity.hide(true)
                
                if(error != nil)
                {
                    let userMessage = error!.localizedDescription
                    let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    
                    myAlert.addAction(okAction)
                    
                    self.presentViewController(myAlert, animated: true, completion: nil)
                    
                    PFUser.logOut()
                    return
                }
                
                if(success)
                {
                    if !userId.isEmpty
                    {
                        NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "user_name")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.buildUserInterface()
                        }
                    }
                }
            })
        })
    }
}


//
//  LeftSideViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse

class LeftSideViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var menuItems:[String] = ["Explore Galleries", "Change Password"]
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    
    @IBOutlet weak var SignOutButtonOutlet: UIButton!
    
    // SIGN OUT
    @IBAction func ButtonTapped(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_name")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Signing Out"
        spiningActivity.detailsLabelText = "Please wait"
        
        
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            
            
            spiningActivity.hide(true)
            
            
            // Navigate to Protected page
            let mainStoryBoard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            let signInPage:ViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            let signInPageNav = UINavigationController(rootViewController:signInPage)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = signInPageNav
            
        }
    }
    
    
    // VIEW DID LOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Hide Navigation Controller
        self.navigationController?.navigationBarHidden = true;
        
        userProfilePicture.layer.cornerRadius   = userProfilePicture.frame.size.width / 2
        userProfilePicture.layer.borderWidth    = 2.0
        userProfilePicture.clipsToBounds        = true
        
        // Format with rounded corners
        SignOutButtonOutlet.layer.cornerRadius = 5
        
        loadUserDetails()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        myCell.textLabel?.text = menuItems[indexPath.row]
        
        return myCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch(indexPath.row)
        {
        case 0:
            // Open Gallery List
            
            let mainPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainPageViewController") as! MainPageViewController
            
            let mainPageNav = UINavigationController(rootViewController: mainPageViewController)
            
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.drawerContainer!.centerViewController = mainPageNav
            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            
            break
            
//        case 1:
//            // Open Event page
//            let eventPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EventListViewController") as! ARTEventListViewController
//            let eventPageNav = UINavigationController(rootViewController: eventPageViewController)
//            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            appDelegate.drawerContainer!.centerViewController = eventPageNav
//            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break
//            
//        case 2:
//            // Open Artist page
//            let artistPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ArtistListViewController") as! ARTArtistListsCollectionViewController
//            let artistPageNav = UINavigationController(rootViewController: artistPageViewController)
//            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            appDelegate.drawerContainer!.centerViewController = artistPageNav
//            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break
//            
//        case 3:
//            // Open Art page
//            let artPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ArtListViewController") as! ARTArtListCollectionViewController
//            let artPageNav = UINavigationController(rootViewController: artPageViewController)
//            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            appDelegate.drawerContainer!.centerViewController = artPageNav
//            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break
//            
//        case 4:
//            // Open Friends
//            let friendsPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FriendsViewController") as! ARTFriendsTableViewController
//            let friendsPageNav = UINavigationController(rootViewController: friendsPageViewController)
//            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            appDelegate.drawerContainer!.centerViewController = friendsPageNav
//            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break
//            
//        case 5:
//            // Open Settings
//            let settingsPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsTableViewController") as! ARTSettingsTableViewController
//            let settingsPageNav = UINavigationController(rootViewController: settingsPageViewController)
//            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            
//            appDelegate.drawerContainer!.centerViewController = settingsPageNav
//            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
//            break
            
            //       case 5:
            //            // Open About page
            //            let aboutPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AboutViewController") as! ARTAboutViewController
            //            let aboutPageNav = UINavigationController(rootViewController: aboutPageViewController)
            //            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //
            //            appDelegate.drawerContainer!.centerViewController = aboutPageNav
            //            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            //            break
            
            //       case 6:
            //                // Open Terms $ Conditions
            //            let termsPageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TermsAndConditionsViewController") as! TermsAndConditionsViewController
            //            let termsPageNav = UINavigationController(rootViewController: termsPageViewController)
            //            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //
            //            appDelegate.drawerContainer!.centerViewController = termsPageNav
            //            appDelegate.drawerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
            //            break
            
        default:
            print("Menu option not handled")
        }
    }
    
    // View Profile Button
    @IBAction func editButtonTapped(sender: AnyObject) {
        let editProfile = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfileTableViewController") as! ARTEditProfileTableViewController
        //editProfile.opener = self
        
        let editProfileNav = UINavigationController(rootViewController: editProfile)
        self.presentViewController(editProfileNav, animated: true, completion: nil)
    }
    
    func loadUserDetails()
    {
        if(PFUser.currentUser() == nil)
        {
            return
        }
        
        let userFirstName = PFUser.currentUser()?.objectForKey("first_name") as? String
        
        if userFirstName == nil
        {
            return
        }
        
        let userLastName = PFUser.currentUser()?.objectForKey("last_name") as! String
        
        userFullNameLabel.text = userFirstName! + " " + userLastName
        
        let profilePictureObject = PFUser.currentUser()?.objectForKey("profile_picture") as? PFFile
        
        if(profilePictureObject != nil)
        {
            profilePictureObject!.getDataInBackgroundWithBlock { (imageData:NSData?, error:NSError?) -> Void in
                
                if(imageData != nil)
                {
                    self.userProfilePicture.image = UIImage(data: imageData!)
                }
            }
        }
    }
}

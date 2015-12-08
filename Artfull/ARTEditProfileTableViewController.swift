//
//  ARTEditProfileTableViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class ARTEditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    // Variables for cell heights
    var rolePickerCellHeight :      CGFloat = 130
    var roleProfileCellHeight :     CGFloat = 0
    var galleryOwnerCellHeight :    CGFloat = 0
    var artistCellHeight :          CGFloat = 0
    
    // Button Outlets
    @IBOutlet weak var modifyListingButtonOutlet:   UIButton!
    @IBOutlet weak var addEventButtonOutlet:        UIButton!
    @IBOutlet weak var userButtonOutlet:            UIButton!
    @IBOutlet weak var galleryButtonOutlet:         UIButton!
    @IBOutlet weak var artistButtonOutlet:          UIButton!
    
    @IBOutlet weak var galleryImage:                UIImageView!
    
    // Text Fields Outlets
    @IBOutlet weak var fullNameTextField:           UITextField!
    @IBOutlet weak var firstNameTextField:          UITextField!
    @IBOutlet weak var lastNameTextField:           UITextField!
    @IBOutlet weak var emailTextField:              UITextField!
    @IBOutlet weak var phoneTextField:              UITextField!
    @IBOutlet weak var identifiedAsTextField:       UITextField!
    @IBOutlet weak var locationTextField:           UITextField!
    
    
    // Table Cell Outlets
    @IBOutlet weak var roleProfileCellOutlet:       UIView!
    @IBOutlet weak var galleryOwnerCellOutlet:      UITableViewCell!
    @IBOutlet weak var artistCellOutlet:            UITableViewCell!
    @IBOutlet weak var rolePickerCellOutlet:        UITableViewCell!
    
    @IBOutlet weak var profilePictureImageView:     UIImageView!
    @IBOutlet var editProfileTableView:             UITableView!
    
    
    // Choose your role User / Artist / Gallery
    @IBAction func changeRoleButtonTapped(sender: AnyObject)
    {
        roleProfileCellHeight                       = 0
        artistCellHeight                            = 0
        galleryOwnerCellHeight                      = 0
        rolePickerCellHeight                        = 130
        
        self.tableView.reloadData()
    }
    
    // User role chosen
    @IBAction func userButtonTapped(sender: AnyObject)
    {
        identifiedAsTextField.text              = "You are identified as a User"
        roleProfileCellOutlet.backgroundColor   = UIColor.blackColor()
        roleProfileCellHeight                   = 33
        artistCellHeight                        = 0
        galleryOwnerCellHeight                  = 0
        rolePickerCellHeight                    = 0
        
        self.tableView.reloadData()
    }
    
    // Artist role chosen
    @IBAction func artistButtonTapped(sender: AnyObject)
    {
        identifiedAsTextField.text              = "You are identified as an Artist"
        roleProfileCellOutlet.backgroundColor   = UIColor.purpleColor()
        roleProfileCellHeight                   = 33
        artistCellHeight                        = 170
        galleryOwnerCellHeight                  = 0
        rolePickerCellHeight                    = 0
        
        self.tableView.reloadData()
    }
    
    // Gallery role chosen
    @IBAction func galleryButtonTapped(sender: AnyObject)
    {
        identifiedAsTextField.text              = "You are identified as a Gallery Manager"
        roleProfileCellOutlet.backgroundColor   = UIColor.blueColor()
        roleProfileCellHeight                   = 33
        artistCellHeight                        = 0
        galleryOwnerCellHeight                  = 170
        rolePickerCellHeight                    = 0
        
        self.tableView.reloadData()
    }
    
    // Close/Save button tapped
    @IBAction func closeButtonTapped(sender: AnyObject) {
        
        // Get current user
        let myUser:PFUser = PFUser.currentUser()!
        
        // Get profile image data
        let profileImageData = UIImageJPEGRepresentation(profilePictureImageView.image!, 1)
        
        // Check if all fields are empty
        if(firstNameTextField.text!.isEmpty && lastNameTextField.text!.isEmpty && (profileImageData == nil))
        {
            let myAlert = UIAlertController(title:"Alert", message:"All fields cannot be empty", preferredStyle: UIAlertControllerStyle.Alert);
            
            let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction);
            self.presentViewController(myAlert, animated:true, completion:nil);
            return
        }
        
        // Check if First name and Last name are not empty
        if(firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty)
        {
            SCLAlertView().showNotice("Oopss", subTitle: "First name and Last name are required fields")
            self.presentationController
            return
        }
        
        // Set new values for user first name and last name
        let userFirstName   = firstNameTextField.text
        let userLastName    = lastNameTextField.text
        let userEmail       = emailTextField.text
        let userPhone       = phoneTextField.text
        
        myUser.setObject(userFirstName!,    forKey: "first_name")
        myUser.setObject(userLastName!,     forKey: "last_name")
        myUser.setObject(userEmail!,        forKey: "username")
        myUser.setObject(userPhone!,        forKey: "user_phone")
        
        // Set profile picture
        if(profileImageData != nil)
        {
            let profileFileObject = PFFile(data:profileImageData!)
            myUser.setObject(profileFileObject!, forKey: "profile_picture")
        }
        
        // Display activity indicator
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.labelText = "Saving.."
        
        myUser.saveInBackgroundWithBlock { (success, error) -> Void in
            
            // Hide activity indicator
            loadingNotification.hide(true)
            
            if(error != nil)
            {
                let myAlert = UIAlertController(title:"Alert", message:error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert);
                
                let okAction =  UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                myAlert.addAction(okAction);
                self.presentViewController(myAlert, animated:true, completion:nil);
                
                return
            }
            if(success)
            {
                
                //alert "Profile details successfully updated" ?
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    //  self.opener.loadUserDetails()
                })
                //
                //                })
                //
                //                myAlert.addAction(okAction);
                //                self.presentViewController(myAlert, animated:true, completion:nil);
            }
            
        }
    }
    //self.dismissViewControllerAnimated(true, completion: nil)
    
    
    // Hide Status Bar
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    // Choose profile picture button
    @IBAction func chooseProfileButtonTapped(sender: AnyObject) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        profilePictureImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        profilePictureImageView.clipsToBounds = true
        profilePictureImageView.layer.borderWidth = 3.0
        //profilePictureImageView.layer.borderColor = CGColor.2
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // VIEW DID LOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Hide the Navigation Bar
        self.navigationController?.navigationBarHidden = true;
        
        // Formatting Picture and buttons
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width / 2
        profilePictureImageView.clipsToBounds = true
        profilePictureImageView.layer.borderWidth = 3.0
        
        
        // Try blurry code
        // let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        // let blurView = UIVisualEffectView(effect: darkBlur)
        // blurView.frame = galleryImage.bounds
        // galleryImage.addSubview(blurView)
        
        // Load user details
        let userFirstName       = PFUser.currentUser()?.objectForKey("first_name") as! String
        let userLastName        = PFUser.currentUser()?.objectForKey("last_name") as! String
        let userEmail           = PFUser.currentUser()?.objectForKey("username") as! String
        let userPhone           = PFUser.currentUser()?.objectForKey("user_phone") as! String
        
        
        
        firstNameTextField.text = userFirstName
        
        lastNameTextField.text  = userLastName
        
        emailTextField.text     = userEmail.lowercaseString
        
        phoneTextField.text     = userPhone
        
        fullNameTextField.text  = userFirstName + " " + userLastName
        
        if(PFUser.currentUser()?.objectForKey("profile_picture") != nil)
        {
            let userImageFile:PFFile = PFUser.currentUser()?.objectForKey("profile_picture") as! PFFile
            
            userImageFile.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                
                if(imageData != nil)
                {
                    self.profilePictureImageView.image = UIImage(data: imageData!)
                }
            })
        }
    }
    
    
    // Dynamic heights modification
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        // Basic
        if indexPath.row == 0 {
            return 194
        }
        // Facebook
        if indexPath.row == 1 {
            return 66
        }
        // User Basic Details
        if indexPath.row == 2 {
            return 110
        }
        // Tell us who you are
        if indexPath.row == 3 {
            return rolePickerCellHeight
        }
        // Identified as (33)
        if indexPath.row == 4 {
            return roleProfileCellHeight
        }
        // XX (66)
        if indexPath.row == 7 {
            return 66
        }
        return 170
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 8
    }
    
}

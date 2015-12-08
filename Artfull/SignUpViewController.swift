//
//  SignUpViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import SCLAlertView
import Mixpanel

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userPasswordRepeatTextField: UITextField!
    @IBOutlet weak var userFirstNameTextField: UITextField!
    @IBOutlet weak var userLastNameTextField: UITextField!
    
    // White Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Change the color of the placeholder in the text fields
        let attributedFirstNamePlaceholder = NSAttributedString(string: "First Name", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userFirstNameTextField.attributedPlaceholder = attributedFirstNamePlaceholder
        
        let attributedLastNamePlaceholder = NSAttributedString(string: "Last Name", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userLastNameTextField.attributedPlaceholder = attributedLastNamePlaceholder
        
        let attributedEmailPlaceholder = NSAttributedString(string: "Email Address", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userEmailAddressTextField.attributedPlaceholder = attributedEmailPlaceholder
        
        let attributedPasswordPlaceholder = NSAttributedString(string: "Password", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userPasswordTextField.attributedPlaceholder = attributedPasswordPlaceholder
        
        let attributedPasswordRepeatPlaceholder = NSAttributedString(string: "Repeat Password", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userPasswordRepeatTextField.attributedPlaceholder = attributedPasswordRepeatPlaceholder
        
        // Recognize tap gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("screenTapped"))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        userPasswordRepeatTextField.returnKeyType = UIReturnKeyType.Done
        userPasswordRepeatTextField.delegate = self
    }
    
    // Dismiss Keyboard when tapped out of the text fields
    func screenTapped()
    {
        for subview in view.subviews
        {
            if(subview.isFirstResponder())
            {
                subview.resignFirstResponder()
            }
        }
    }
    
    // Keyboard 'Next' (Return key) behavior
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if (textField == userFirstNameTextField) {
            userLastNameTextField.becomeFirstResponder()
        } else if (textField == userLastNameTextField) {
            userEmailAddressTextField.becomeFirstResponder()
        } else if (textField == userEmailAddressTextField) {
            userPasswordTextField.becomeFirstResponder()
        } else if (textField == userPasswordTextField) {
            userPasswordRepeatTextField.becomeFirstResponder()
        } else if (textField == userPasswordRepeatTextField) {
            userPasswordRepeatTextField.resignFirstResponder()
            signUpButtonTapped(true)
        }
        return true
    }
    
    
    override func viewDidLayoutSubviews()
    {
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectProfilePhotoButtonTapped(sender: AnyObject)
    {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        profilePhotoImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func repeatPasswordEditingEnded(sender: AnyObject) {
        
    }
    
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        
        view.endEditing(true)
        
        let userName = userEmailAddressTextField.text
        let userPassword = userPasswordTextField.text
        let userPasswordRepeat = userPasswordRepeatTextField.text
        let userFirstName = userFirstNameTextField.text
        let userLastName = userLastNameTextField.text
        
        if(userName!.isEmpty || userPassword!.isEmpty || userPasswordRepeat!.isEmpty || userFirstName!.isEmpty || userLastName!.isEmpty)
        {
            // Display error message
            SCLAlertView().showNotice("Please Try Again", subTitle: "All fields are required")
            return
        }
        
        if(userPassword != userPasswordRepeat)
        {
            // Display error message
            SCLAlertView().showNotice("Please Try Again", subTitle: "Passwords do not match.")
            return
        }
        
        let myUser:PFUser = PFUser()
        myUser.username = userName
        myUser.password = userPassword
        myUser.email = userName
        myUser.setObject(userFirstName!, forKey: "first_name")
        myUser.setObject(userLastName!, forKey: "last_name")
        
        if let profileImageData = profilePhotoImageView.image
        {
            let profileImageDataJPEG = UIImageJPEGRepresentation(profileImageData, 1)
            
            let profileImageFile = PFFile(data: profileImageDataJPEG!)
            myUser.setObject(profileImageFile!, forKey: "profile_picture")
        }
        
        // Show activity indicator
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Sending"
        spiningActivity.detailsLabelText = "Please wait"
        
        myUser.signUpInBackgroundWithBlock { (success, error) -> Void in
            
            // Hide activity indicator
            spiningActivity.hide(true)
            
            var userMessage = "Registration successful. Thank you!"
            
            if(!success)
            {
                //userMessage = "Could not register at this time please try again later."
                userMessage = error!.localizedDescription
            }
            
            
            let myAlert = UIAlertController(title:"Alert", message:userMessage, preferredStyle:UIAlertControllerStyle.Alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default){ action in
                
                if(success)
                {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            }
            
            myAlert.addAction(okAction)
            
            self.presentViewController(myAlert, animated: true, completion: nil)
            
        }
    }
}

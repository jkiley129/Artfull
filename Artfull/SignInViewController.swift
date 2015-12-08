//
//  SignInViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/3/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class SignInViewController: UIViewController
{
    
    // Make the status bar White
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
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
    
    // Declaration for the text entry fields
    @IBOutlet weak var userEmailAddressTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    // Close Button
    @IBAction func closeButtonTapped(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func signInButtonTapped(sender: AnyObject)
    {
        view.endEditing(true)
        
        let userEmail = userEmailAddressTextField.text?.lowercaseString
        let userPassword = userPasswordTextField.text?.lowercaseString
        
        if(userEmail!.isEmpty || userPassword!.isEmpty)
        {
            return
        }
        
        // Display activity animation
        let spiningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spiningActivity.labelText = "Sending"
        spiningActivity.detailsLabelText = "Please wait"
        //spiningActivity.userInteractionEnabled = false
        
        
        PFUser.logInWithUsernameInBackground(userEmail!, password: userPassword!) { (user:PFUser?, error:NSError?) -> Void in
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if(user != nil)
            {
                
                // Remember the sign in state
                let userName:String? = user?.username
                
                NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "user_name")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Navigate to Protected page
                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.buildUserInterface()
                
            } else {
                
                // Display error message
                SCLAlertView().showNotice("Oopss", subTitle: error!.localizedDescription)
            }
        }
    }
    
    // Keyboard 'Next' (Return key) behavior
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == userEmailAddressTextField) {
            userPasswordTextField.becomeFirstResponder()
        } else if (textField == userPasswordTextField) {
            userPasswordTextField.resignFirstResponder()
            signInButtonTapped(true)
        }
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Format the logo with rounded corners
//        logoOutlet.layer.cornerRadius = 5
        
        // Change the color of the placeholder in the text fields
        let attributedEmailPlaceholder = NSAttributedString(string: "EMAIL ADDRESS", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userEmailAddressTextField.attributedPlaceholder = attributedEmailPlaceholder
        
        let attributedPasswordPlaceholder = NSAttributedString(string: "PASSWORD", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        userPasswordTextField.attributedPlaceholder = attributedPasswordPlaceholder
        
        // Recognize tap gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("screenTapped"))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        //firstResponderDelay()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        NSThread.sleepForTimeInterval(0.5)
        userEmailAddressTextField.becomeFirstResponder()
    }
}


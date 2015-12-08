//
//  PasswordResetViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView

class PasswordResetViewController: UIViewController {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    // Close Button
    @IBAction func closeButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // White Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Dismiss Keyboard when tapped out of the text fields (Not Working)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the color of the placeholder in the text fields
        let attributedEmailPlaceholder = NSAttributedString(string: "E-mail address", attributes: [ NSForegroundColorAttributeName: UIColor.whiteColor() ])
        emailAddressTextField.attributedPlaceholder = attributedEmailPlaceholder
        
        // Recognize tap gesture
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("screenTapped"))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        let emailAddress = emailAddressTextField.text
        
        if emailAddress!.isEmpty
        {
            // Display error message
            SCLAlertView().showNotice("Oupss", subTitle: "Please type in your email address.")
            return
        }
        
        PFUser.requestPasswordResetForEmailInBackground(emailAddress!, block: { (success, error) -> Void in
            
            if(error != nil)
            {
                // Display error message
                SCLAlertView().showNotice("Oupss", subTitle: error!.localizedDescription)
            } else {
                // Display success message
                SCLAlertView().showInfo("Success", subTitle: "An email message was sent to you \(emailAddress)")
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }
        })
    }
}

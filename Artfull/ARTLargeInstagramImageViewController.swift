//
//  ARTLargeInstagramImageViewController.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit

class ARTLargeInstagramImage: UIViewController {
    
    var instagramImage : UIImage!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.mainImageView.image = instagramImage
        self.backgroundImageView.image = instagramImage
        
        self.view.backgroundColor = UIColor(colorLiteralRed: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)
        
        let dismissButton = UIButton(frame: self.view.frame)
        
        dismissButton.backgroundColor = UIColor.clearColor()
        dismissButton.addTarget(self, action: "dismissVC", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.insertSubview(dismissButton, belowSubview: self.mainImageView)
        self.mainImageView.userInteractionEnabled = false
        
    }
    
    
    func dismissVC() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

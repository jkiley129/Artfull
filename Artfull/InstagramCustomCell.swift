//
//  InstagramCustomCell.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import Foundation
import AlamofireImage

class InstagramCustomCell: UICollectionViewCell {
    
    @IBOutlet weak var instagramImage: UIImageView!
    var imageURL : NSURL = NSURL() {
        didSet {
            if imageURL != NSURL() {
                instagramImage.af_setImageWithURL(imageURL, imageTransition: UIImageView.ImageTransition.FlipFromBottom(0.5))
            }
            else
            {
                instagramImage.image = UIImage(named: "Icon-76")
            }
        }
    }
    
    
    
    
}


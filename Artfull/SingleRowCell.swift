//
//  SingleRowCell.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit

class SingleRowCell: UITableViewCell
{
    var galleryDescriptionCell                  = ""
    var galleryOwnerCell                        = ""
    var galleryOpeningHoursCell                 = ""
    var galleryStreetNameCell                   = ""
    var galleryPhoneNumberCell                  = ""
    var galleryWebsiteCell                      = ""
    
    @IBOutlet weak var swiftgramImageView:      UIImageView!
    @IBOutlet weak var galleryNameCell:         UITextField!
    @IBOutlet weak var galleryNeighborhoodCell: UITextField!
    @IBOutlet weak var galleryDistanceCell:     UITextField!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Formatting buttons
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


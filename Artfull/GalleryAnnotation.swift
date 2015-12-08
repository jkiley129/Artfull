//
//  GalleryAnnotation.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import Foundation
import MapKit
import Parse
import Contacts

class GalleryAnnotation : NSObject, MKAnnotation {
    
    let title: String?
    let locationName : String
    let coordinate : CLLocationCoordinate2D
    let galleryObject : PFObject
    
    
    convenience init?(galleryObject: PFObject){
        if let newLocationText = galleryObject["Gallery_Name"] as? String,
            let newLocationDetailText = galleryObject["Neighborhood"] as? String,
            let newGalleryLocation = galleryObject["Location"] as? CLLocationCoordinate2D{
                self.init(title: newLocationText, locationName: newLocationDetailText, coordinate: newGalleryLocation, galleryObject: galleryObject)
        }else{
            return nil
        }
    }
    
    init (title: String, locationName: String, coordinate: CLLocationCoordinate2D, galleryObject: PFObject) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.galleryObject = galleryObject
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem? {
        
        if let title = title{
            let addressDictionary = [String(CNPostalAddressStreetKey): title]
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
            
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = title
            return mapItem
        }
        return nil
    }
    
}


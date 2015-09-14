//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/11/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    struct Keys {
        static let PhotoID = "id"
        static let PhotoTitle = "title"
        static let PhotoUrl = "url"
    }
    
    @NSManaged var photoID: String
    @NSManaged var photoTitle: String
    @NSManaged var photoUrl: String
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        photoID = dictionary[Keys.PhotoID] as! String
        photoTitle = dictionary[Keys.PhotoTitle] as! String
        photoUrl = dictionary[Keys.PhotoUrl] as! String
    }
    
    var image: UIImage? {
        get {
            return Client.Caches.imageCache.imageWithIdentifier(photoID)
        } set {
            Client.Caches.imageCache.storeImage(image, identifier: photoID)        }
    }
}

//
//  Convenience.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/12/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation
import MapKit

extension Client {
    
    func getImageFromFlicker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, boxSize: Double, completionHandler: (success: Bool, dictionary: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        //Create a boundedBox so limit the number of picture we get
        println("The box size is \(boxSize)")
        var boundedBox: String {
            return "\(longitude - boxSize),\(latitude - boxSize),\(longitude + boxSize),\(latitude + boxSize)"
        }
        
        /* 1. Set the parameters */
        let parameters : [String:AnyObject] = [
            Parameters.Method: Methods.PhotoSearch,
            Parameters.ApiKey: Constants.ApiKey,
            Parameters.BBox: boundedBox,
            Parameters.SafeSearch: Constants.SafeSearch,
            Parameters.Extras: Constants.Extras,
            Parameters.Format: Constants.Format,
            Parameters.NoJSONCallBack: Constants.NoJSONCallBack,
            Parameters.PerPage: Constants.PerPage,
            Parameters.Page: self.page
        ]
        /* 2/3. Build the URL and configure the request */
        /* 4. Make the request */
        self.count = 0
        let task = taskForFlickrGet(parameters) { (JSONResults, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, dictionary: nil, errorString: "Could not complete request \(error)")
            } else {
                if let photoDic = JSONResults.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject] {
                    if let photos = photoDic[JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                        println("The number of photos: \(photos.count)")
                        if (photos.count < 24) {
                            completionHandler(success: false, dictionary: nil, errorString: "Could not complete request \(error)")
                        } else {
                            var resultsDic = [[String:AnyObject]]()
                        
                            do {
                                let photo = photos[self.count]
                                resultsDic.append(photo)
                                self.count = self.count + 1
                            } while (self.count % 24 != 0)
                            self.page = self.page + 1
                        
                        completionHandler(success: true, dictionary: resultsDic, errorString: nil)
                        }
                    }
                } else {
                    completionHandler(success: false, dictionary: nil, errorString: "Could not complete request \(error)")
                }
            }
        }
    }
}

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
    
    func getImageFromFlicker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completionHandler: (success: Bool, dictionary: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        //Create a boundedBox so limit the number of picture we get
        var boundedBox: String {
            return "\(longitude - 0.01),\(latitude - 0.01),\(longitude + 0.01),\(latitude + 0.01)"
        }
        
        /* 1. Set the parameters */
        let parameters : [String:AnyObject] = [
            Parameters.Method: Methods.PhotoSearch,
            Parameters.ApiKey: Constants.ApiKey,
            Parameters.BBox: boundedBox,
            Parameters.SafeSearch: Constants.SafeSearch,
            Parameters.Extras: Constants.Extras,
            Parameters.Format: Constants.Format,
            Parameters.NoJSONCallBack: Constants.NoJSONCallBack
        ]
        /* 2/3. Build the URL and configure the request */
        /* 4. Make the request */
        let task = taskForFlickrGet(parameters) { (JSONResults, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, dictionary: nil, errorString: "Could not complete request \(error)")
            } else {
                if let photoDic = JSONResults.valueForKey(JSONResponseKeys.Photos) as? [String: AnyObject] {
                    if let photos = photoDic[JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                        var resultsDic = [[String:AnyObject]]()
                        
                        do {
                            let photo = photos[self.count]
                            resultsDic.append(photo)
                            self.count = self.count + 1
                        } while (self.count % 12 != 0)
                        
                        completionHandler(success: true, dictionary: resultsDic, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, dictionary: nil, errorString: "Could not complete request \(error)")
                }
            }
        }
    }
}

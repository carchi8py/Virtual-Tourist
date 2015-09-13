//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/12/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation

extension Client {
    struct Constants {
        static let FlickrBaseUrl = "https://api.flickr.com/services/rest/"
        static let ApiKey = "82f838e6ec0855fcfc15838a9f8ed333"
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let Format = "json"
        static let NoJSONCallBack = "1"
    }
    
    struct Parameters {
        static let Method = "method"
        static let ApiKey = "api_key"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
    }
    
    struct Methods {
        static let PhotoSearch = "flickr.photos.search"
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let ID = "id"
        static let Title = "title"
        static let URL = "url_m"
    }
}
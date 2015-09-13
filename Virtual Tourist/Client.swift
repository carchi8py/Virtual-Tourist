//
//  Client.swift
//  Virtual Tourist
//
//  Created by Chris Archibald on 9/12/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation

class Client: NSObject {
    
    // Shared Session
    var session: NSURLSession
    
    // Stored count of the number of picture we have gotten from flickr
    var count = 0
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    /***** Flickr Calls *****/
    
    func taskForFlickrGet(parameters: [String : AnyObject], completionHandler: (results: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.FlickrBaseUrl + Client.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { data, responce, downloadError in
            if let error = downloadError {
                completionHandler(results: nil, error: downloadError)
            } else {
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                Client.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        let url = NSURL(string: filePath)!
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { data, responce, downloadError in
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        task.resume()
        return task
    }
    
    /***** Helper Functions *****/
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            print("Error in json")
            completionHandler(result: nil, error: error)
        } else {
            print("We are good in json")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    //The shared Instance
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
}

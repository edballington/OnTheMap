//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Ed Ballington on 11/29/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//

import Foundation

class OTMClient: NSObject {
    
    //MARK: Properties
    
    /* Shared Session */
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : String? = nil
    var objectID : String? = nil
    
    /* Student Name */
    var firstName : String? = nil
    var lastName : String? = nil
    

    //MARK: Initializer
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: GET
    
    func taskForUdacityGETMethod(method: String, userID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
       
        /* Build URL */
        let urlString = Constants.UdacityBaseURLSecure + method + "/" + userID
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* Make request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* Check for error */
            guard (error == nil) else {
                print("There was an error with your Udacity GET request: \(error)")
                return
            }
            
            /* Check for a successful 2XX response */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your Udacity GET request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your Udacity GET request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your Udacity GET request returned an invalid response!")
                }
                
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler)
            First skip the first 5 characters of the response (Security characters used by Udacity) */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            
        }
        
        /* Start the request */
        task.resume()
        
        return task

    }
    
    func taskForParseGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        /* Build URL */
        let urlString = Constants.ParseBaseURLSecure + method + OTMClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OTMClient.Constants.ParseApplicationID, forHTTPHeaderField: OTMClient.ParameterKeys.ApplicationID)
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: OTMClient.ParameterKeys.ApiKey)
        
        /* Make request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* Check for error */
            guard (error == nil) else {
                print("There was an error with your Parse GET request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Check for a successful 2XX response */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your Parse GET request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your Parse GET request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your Parse GET request returned an invalid response!")
                }
                
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /*  Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        /* Start the request */
        task.resume()
        
        return task
        
    }
    
    func taskForParseGETQueryMethod(method: String, parameters: String, completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build URL */
        let urlString = Constants.ParseBaseURLSecure + method + parameters
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(OTMClient.Constants.ParseApplicationID, forHTTPHeaderField: OTMClient.ParameterKeys.ApplicationID)
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: OTMClient.ParameterKeys.ApiKey)
        
        /* Make request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* Check for error */
            guard (error == nil) else {
                print("There was an error with your Parse GET request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Check for a successful 2XX response */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your Parse GET Query request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your Parse GET Query request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your Parse GET Query request returned an invalid response!")
                }
                
                completionHandler(result: nil, error: error)
                return
            }
            
            /* Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /*  Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        /* Start the request */
        task.resume()
        
        return task
        
    }

    
    // MARK: POST
    
    func taskForUdacityPOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = Constants.UdacityBaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your Udacity POST request: \(error?.localizedDescription)")
                completionHandler(result: response, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your Udacity POST request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your Udacity POST request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your Udacity POST request returned an invalid response!")
                }
                
                completionHandler(result: response, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler)
               First skip the first 5 characters of the response (Security characters used by Udacity) */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    func taskForParsePOSTMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = Constants.ParseBaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(OTMClient.Constants.ParseApplicationID, forHTTPHeaderField: OTMClient.ParameterKeys.ApplicationID)
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: OTMClient.ParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /*  Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                completionHandler(result: response, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: nil)
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: PUT
    
    func taskForParsePUTMethod(method: String, objectID : String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = Constants.ParseBaseURLSecure + method + "/" + objectID
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.addValue(OTMClient.Constants.ParseApplicationID, forHTTPHeaderField: OTMClient.ParameterKeys.ApplicationID)
        request.addValue(OTMClient.Constants.ParseApiKey, forHTTPHeaderField: OTMClient.ParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        /*  Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(result: nil, error: error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                
                completionHandler(result: response, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(result: nil, error: nil)
                return
            }
            
            /* Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }

    
    
    // MARK: DELETE
    
    func taskForUdacityDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Build the URL and configure the request */
        let urlString = Constants.UdacityBaseURLSecure + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your Udacity DELETE request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your Udacity DELETE request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your Udacity DELETE request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your Udacity DELETE request returned an invalid response!")
                }
                
                completionHandler(result: response, error: error)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data and use the data (happens in completion handler)
            First skip the first 5 characters of the response (Security characters used by Udacity) */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            OTMClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }


    
    // MARK: Helper functions
        
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
            
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
        
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
        
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
            
        completionHandler(result: parsedResult, error: nil)
    }


    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }

    
}

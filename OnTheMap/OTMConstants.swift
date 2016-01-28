//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Ed Ballington on 11/30/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//


extension OTMClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ParseApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: Application ID
        static let ParseApplicationID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: Facebook App ID
        static let FacebookAppID : String = "365362206864879"
        
        // MARK: URLs
        static let ParseBaseURLSecure : String = "https://api.parse.com/1/classes/"
        static let UdacityBaseURLSecure: String = "https://www.udacity.com/api/"
        
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Locations
        static let Location = "StudentLocation"     //Used for Getting or Posting a location
        
        // MARK: Udacity Authentication
        static let Session = "session"
        
        // MARK: Users
        static let Users = "users"
        
        // MARK: Public User Data
        static let AuthenticationTokenNew = "authentication/token/new"
        
    }
    
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let ApiKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
        static let uniqueKey = "uniqueKey"
        static let limit = "limit"
        static let skip = "skip"
        static let order = "order"
        
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
        static let account = "account"
        static let key = "key"
        
        static let uniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
        
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let Session = "session"
        static let sessionID = "id" 
        
        // MARK: Account
        static let UserID = "id"
        static let account = "account"
        static let key = "key"
        
        static let user = "user"
        static let last_name = "last_name"
        static let first_name = "first_name"
        static let results = "results"
        
        // MARK: Student Locations
        static let LocationResults = "results"  
        static let CreatedAt = "createdAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
        
        
    }
    

}

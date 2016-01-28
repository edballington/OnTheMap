//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Ed Ballington on 1/3/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//


struct StudentInformation {
    
    //MARK: Properties
    
    var objectid: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    
    //MARK: Initializer
    
    /* Construct a StudentInformation object from a dictionary */
    init(dictionary: [String: AnyObject?]) {
        
        objectid = dictionary[OTMClient.JSONResponseKeys.objectID] as? String
        uniqueKey = dictionary[OTMClient.JSONResponseKeys.uniqueKey] as? String  //Set this to my Udacity userid
        firstName = dictionary[OTMClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[OTMClient.JSONResponseKeys.LastName] as? String
        mapString = dictionary[OTMClient.JSONResponseKeys.mapString] as? String
        mediaURL = dictionary[OTMClient.JSONResponseKeys.mediaURL] as? String
        latitude = dictionary[OTMClient.JSONResponseKeys.latitude] as? Double
        longitude = dictionary[OTMClient.JSONResponseKeys.longitude] as? Double
        
    }

}

//
//  StudentInformationModel.swift
//  OnTheMap
//
//  Created by Ed Ballington on 1/27/16.
//  Copyright © 2016 Ed Ballington. All rights reserved.
//

import UIKit

class StudentInformationModel: NSObject {
    
    var studentInformationArray = [StudentInformation]()
    
    class func sharedInstance() -> StudentInformationModel {
        
        struct Singleton {
            static var sharedInstance = StudentInformationModel()
        }
        
        return Singleton.sharedInstance
    }


}

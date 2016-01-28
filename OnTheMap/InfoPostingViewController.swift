//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Ed Ballington on 12/5/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit

class InfoPostingViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate  {

//MARK: - Constants
    
    struct Constants {
        static let findButtonLabel = "Find on the Map"
        static let submitButtonLabel = "Submit"
    }
    
//MARK: - Variables
    var userLocationString = String()           //Location string entered by student
    var userLocation = CLLocationCoordinate2D()   //Student Location lat and long for user to post to PARSE
    var userURL = String()                        //Student URL to post to PARSE
    
//MARK: - Properties
    var newStudentLocation = Bool()             //True if posting a new location, false if overwriting an existing one
    
//MARK: - Outlets

    @IBOutlet weak var topFrameView: UIView!    //Input URL here and change color once the location has been successfully geocoded
    @IBOutlet weak var mapFrameView: UIView!    //Add mapView to this frame once location is geocoded
    @IBOutlet weak var buttonFrameView: UIView! //Change color and alpha of bottom frame based on whether location is being input or map is being shown

    @IBOutlet weak var locationTextView: UITextView!    //User entered location goes here
    @IBOutlet weak var URLTextView: UITextView!         //User entered URL goes here
    
    @IBOutlet weak var bottomButton: UIButton!  //Button will change function and title based on whether location or URL is being input
    @IBOutlet weak var cancelButton: UIButton!  //Cancel the info posting


    
//MARK: - View Controller lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //Setup the initial view
        URLTextView.editable = false
        bottomButton.setTitle(Constants.findButtonLabel, forState: .Normal)

    }
    
//MARK: - Actions
    
    @IBAction func cancelInfoPosting(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func bottomButtonClick(sender: UIButton) {
        
        //Check to see whether the button is to find a location or submit the entry
        if bottomButton.currentTitle! == Constants.findButtonLabel {
            
            userLocationString = locationTextView.text
            
            let activityView = showProgressIndicator()
            
            //Try to find the user location
            findEnteredLocation(userLocationString, completionHandler: { (coordinates) -> Void in
                
                //Valid location returned
                if let location = coordinates {
                    
                    self.userLocation = location
                    print("Valid location geocoded: \(self.userLocation.latitude), \(self.userLocation.longitude)")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.displayMapWithUserLocation(self.userLocation)
                        
                        self.unshowProgressIndicator(activityView)
                        
                        self.locationTextView.text = ""
                        self.locationTextView.editable = false
                        self.topFrameView.backgroundColor = UIColor(red: 102.0/255.0, green: 153.0/255.0, blue: 204.0/255.0, alpha: 1.0)
                        self.URLTextView.textColor = UIColor .whiteColor()
                        self.cancelButton.setTitleColor(UIColor .whiteColor(), forState: .Normal)
                        self.URLTextView.editable = true
                        
                        self.buttonFrameView.alpha = 0.5
                        self.bottomButton.setTitle(Constants.submitButtonLabel, forState: .Normal)
                        
                    })
                    
                //Invalid location
                } else {
                    
                    self.unshowProgressIndicator(activityView)
                    
                    //Display alert message for invalid location
                    self.displayAlertMessage("Could not geocode the location")
                
                }
                
            })
            
        //Bottom button function is to submit the location and URL
        } else {
            
            let activityView = showProgressIndicator()
            
            //Carry out submit action
            if URLTextView.text != "" {
                
                userURL = URLTextView.text
                
                //Create the Student Information object for posting to PARSE
                var info = [String : AnyObject?]()
                info[OTMClient.JSONBodyKeys.uniqueKey] = OTMClient.sharedInstance().userID
                info[OTMClient.JSONBodyKeys.FirstName] = OTMClient.sharedInstance().firstName
                info[OTMClient.JSONBodyKeys.LastName] = OTMClient.sharedInstance().lastName
                info[OTMClient.JSONBodyKeys.MapString] = userLocationString
                info[OTMClient.JSONBodyKeys.MediaURL] = userURL
                info[OTMClient.JSONBodyKeys.Latitude] = userLocation.latitude
                info[OTMClient.JSONBodyKeys.Longitude] = userLocation.longitude
                
                let studentInfo = StudentInformation.init(dictionary: info)
                
                if newStudentLocation == true {
                    
                    //Add the new entry to the PARSE database - display alertview if unsuccesful
                    
                    OTMClient.sharedInstance().addStudentInformationToPARSE(studentInfo, completionHandler: { (success, objectId, error) -> Void in
                        
                        self.unshowProgressIndicator(activityView)
                        
                        if let error = error {
                            
                            if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                                self.displayAlertMessage("The internet connection appears to be offline")
                            }
                        }
                        
                        if !success {
                            self.displayAlertMessage("Error posting student information")
                        } else {
                            if let objectId = objectId {
                                print("Posted new location: \(studentInfo)")
                                OTMClient.sharedInstance().objectID = objectId     //Save the objectId
                            } else {
                                OTMClient.sharedInstance().objectID = nil
                            }
                        }
                        
                    })
                    
                } else {
                    
                    //Update existing entry in PARSE - display alertview if unsuccessful
                    
                    OTMClient.sharedInstance().updateStudentInformationInPARSE(OTMClient.sharedInstance().objectID!, studentInfo: studentInfo, completionHandler: { (success, error) -> Void in
                        
                        self.unshowProgressIndicator(activityView)
                        
                        if let error = error {
                            
                            if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                                self.displayAlertMessage("The internet connection appears to be offline")
                            }

                        }
                        
                        if !success {
                            self.displayAlertMessage("Error updating student information")
                        } else {
                            print("Updated location for objectid \(OTMClient.sharedInstance().objectID): \(studentInfo)")
                        }
                        
                    })
                    
                }
                
                dismissViewControllerAnimated(true, completion: nil)
                
                
            } else {
                
                //Nothing entered so display alert view
                displayAlertMessage("Nothing entered for URL")
            }
            
        }
        
        
    }
    
//MARK: - Other Methods
    
    //Reverse geocode the entered location string and return coordinates if valid or nil if invalid
    func findEnteredLocation(location: String, completionHandler: (coordinates: CLLocationCoordinate2D?) -> Void) {
        
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) -> Void in
            
            if let error = error {
                print("Geocoding error: \(error)")
                completionHandler(coordinates: nil)
                
                if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                    self.displayAlertMessage("The internet connection appears to be offline")
                    
                } else {
                        self.displayAlertMessage("Error geocoding address")
                }
                
            } else {
                if let placemark = placemarks?.first {
                    completionHandler(coordinates: placemark.location!.coordinate)
                } else {
                    completionHandler(coordinates: nil)
                }
            }

        }
        
    }
    
    //Display the map in the mapFrame with the location as an annotation
    func displayMapWithUserLocation(location: CLLocationCoordinate2D) -> Void {
        
        let mapView = MKMapView(frame: mapFrameView.bounds)
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        
        mapFrameView.insertSubview(mapView, belowSubview: buttonFrameView)
        
        //Create the annotation and add to the map
        let annotation = MKPointAnnotation()
        
        let lat = CLLocationDegrees(location.latitude)
        let long = CLLocationDegrees(location.longitude)
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        annotation.coordinate = coordinate
        let annotationArray : [MKPointAnnotation] = [annotation]
        
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(annotationArray, animated: true)
        
    }
    
    func displayAlertMessage(message: String) -> Void {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    func showProgressIndicator() -> UIActivityIndicatorView {
        
        //Display progress indicator
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //Display a progress indicator in the center
            activityView.center = self.view.center
            activityView.startAnimating()
            self.view.addSubview(activityView)
        }
        
        return activityView
        
    }
    
    func unshowProgressIndicator(activityView: UIActivityIndicatorView) {
        
        //When downloading is complete remove progress indicator
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
        
    }


    
//MARK: - Delegate Methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        textView.text = ""
        textView.textAlignment = .Left
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        textView.textAlignment = .Center
        
    }
    
    //This delegate function dismisses the keyboard whenever the "Return" or "Done" key is pressed
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    

    

    
}

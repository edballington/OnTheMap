//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Ed Ballington on 11/30/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var isNewStudentLocation = Bool()       //true if this is a new StudentLocation, false if this should overwrite existing one
    

// MARK: - View Controller lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadAnnotations(self)
        
    }
    
    
// MARK: - Actions
    
    @IBAction func logout(sender: AnyObject) {
        
        OTMClient.sharedInstance().logoutWithUdacity(OTMClient.sharedInstance().sessionID!) { success, error in
            
            if let error = error {
                print("Logout failed due to error: \(error)")
            } else {
            
            if success {
                // Segue back to login screen
                self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            }
    }
    
    @IBAction func loadAnnotations(sender: AnyObject) {
        
        /*  Display activity indicator until map and annotations have finished loading */
        let activityView = showProgressIndicator()
        
        /* First retrieve the student annotations dictionary from Parse */
        OTMClient.sharedInstance().getStudentLocations("100") { error in
            
            if let error = error {
                print("Error retrieving annotations from Parse: \(error)")
                
                if error.localizedDescription.containsString("Could not parse getStudentLocations") {
                    self.displayAlertMessage("Error retrieving student data")
                    self.unshowProgressIndicator(activityView)
                    
                } else if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                    self.displayAlertMessage("The internet connection appears to be offline")
                } else {
                    self.displayAlertMessage("Error retrieving student locations")
                    self.unshowProgressIndicator(activityView)
                }

                
            } else if !StudentInformationModel.sharedInstance().studentInformationArray.isEmpty {
                
                var annotations = [MKPointAnnotation]()
                
                /* First remove all of the pre-existing annotations so they don't continually stack on top of one another */
                dispatch_async(dispatch_get_main_queue(), {self.mapView.removeAnnotations(self.mapView.annotations)})
                
                for location in StudentInformationModel.sharedInstance().studentInformationArray {
                    let annotation = OTMClient.sharedInstance().createAnnotationFromStudentInformation(location)
                    annotations.append(annotation)
                }
                
                dispatch_async(dispatch_get_main_queue(), {self.mapView.addAnnotations(annotations)})
                self.unshowProgressIndicator(activityView)
                
            } else {
                print("Error - no annotations downloaded from Parse")
            }
        }
        
    }

    
    @IBAction func addStudentLocation(sender: AnyObject) {
        
        OTMClient.sharedInstance().checkForDuplicateStudentInformation(OTMClient.sharedInstance().userID!) { (duplicateFound, error) -> Void in
            if let error = error {
                print("Error checking for duplicate student info: \(error)")
                
                if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                    self.displayAlertMessage("The internet connection appears to be offline")
                } else {
                    self.displayAlertMessage("Error checking for duplicate student location")
                }
                
            }
            if duplicateFound {
                
                //Previous entry for this student
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertController(title: nil, message: "User \(OTMClient.sharedInstance().firstName!) \(OTMClient.sharedInstance().lastName!) has already posted a Student Location.  Would you like to overwrite this location?", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                        
                        //Set variable indicating previous entry exists and segue
                        self.isNewStudentLocation = false
                        self.performSegueWithIdentifier("infoPostingSegueFromMap", sender: nil)
                        
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
                
            } else {
                //No previous entry for this student
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    //Set variable indicating no previous entry exists and segue
                    self.isNewStudentLocation = true
                    self.performSegueWithIdentifier("infoPostingSegueFromMap", sender: nil)
                })
                
            }
        }
        
    }
    

// MARK: - Other Methods

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "infoPostingSegueFromMap" {
            
            if let destination = segue.destinationViewController as? InfoPostingViewController {
                destination.newStudentLocation = isNewStudentLocation
            }
            
        }
        
    }
    
    
    func showProgressIndicator() -> UIActivityIndicatorView {
        
        //When downloading new annotations display progress indicator
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //Display a progress indicator in the center
            activityView.center = self.mapView.center
            activityView.startAnimating()
            self.mapView.addSubview(activityView)
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
        
    func displayAlertMessage(message: String) -> Void {
            
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
            
    }


    // MARK: - MKMapViewDelegate methods

    // Create a view with a "right callout accessory view".
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                let isValidURL = app.openURL(NSURL(string: toOpen)!)
                
                //Display an alertView if the URL can't be opened
                if !isValidURL {
                    let alert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                }
            }
        }

}

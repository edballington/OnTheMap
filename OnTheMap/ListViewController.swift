//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Ed Ballington on 11/30/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var isNewStudentLocation = Bool()
    
    
//MARK: - ViewController Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loadStudentInformation(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "infoPostingSegueFromList" {
            
            if let destination = segue.destinationViewController as? InfoPostingViewController {
                destination.newStudentLocation = isNewStudentLocation
            }
            
        }
        
    }

    
//MARK: - IBActions
    
    @IBAction func loadStudentInformation(sender: AnyObject) {
        
        let activityView = showProgressIndicator()
        
        OTMClient.sharedInstance().getStudentLocations("100") { (error) -> Void in
            
            if let error = error {
                print("Error retrieving student locations from Parse: \(error)")
                
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.unshowProgressIndicator(activityView)
                })
                
            } else {
                print("Error - no student information downloaded from Parse")
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
                        self.performSegueWithIdentifier("infoPostingSegueFromList", sender: nil)
                        
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
                
            } else {
                //No previous entry for this student
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    //Set variable indicating no previous entry exists and segue
                    self.isNewStudentLocation = true
                    self.performSegueWithIdentifier("infoPostingSegueFromList", sender: nil)
                })
                
            }
        }

        
    }
    
    
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
    
    //MARK: - TableView Delegate methods

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /* When user taps on desired tableView row open the URL specified in the subtitle */
        
            let app = UIApplication.sharedApplication()
            if let URLtoOpen = tableView.cellForRowAtIndexPath(indexPath)?.detailTextLabel?.text {
                let isValidURL = app.openURL(NSURL(string: URLtoOpen)!)
                
                //Display an alertView if the URL can't be opened
                if !isValidURL {
                    let alert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {self.presentViewController(alert, animated: true, completion: nil)})
                }
                
            }

    }

    //MARK: - TableViewDataSource methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentInformation", forIndexPath: indexPath) as UITableViewCell
        
        //Configure the cell
        let info = StudentInformationModel.sharedInstance().studentInformationArray[indexPath.row]
        cell.textLabel!.text = info.firstName! + " " + info.lastName!
        cell.detailTextLabel!.text = info.mediaURL!
        cell.imageView?.image = UIImage.init(named: "pin")
     
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Defines the number of rows
        
        let count = StudentInformationModel.sharedInstance().studentInformationArray.count
        return count
        
    }

    
    
    //MARK: Helper methods
    
    func showProgressIndicator() -> UIActivityIndicatorView {
        
        //When downloading new listings display progress indicator
        
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
        
        //When downloading is complete progress indicator
        
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
    
}

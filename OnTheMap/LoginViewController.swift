//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ed Ballington on 11/24/15.
//  Copyright © 2015 Ed Ballington. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var invalidLoginLabel: UILabel!
    
    private var errorMessage = String()
    
    @IBAction func login() {
        
        self.view.endEditing(true)  //Dismiss the keyboard
        
        // Start animating an activity indicator until the login process either fails or completes
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        OTMClient.sharedInstance().authenticateWithUdacity(emailTextField.text!, password: passwordTextField.text!) { (sessionID, userID, error) in
            
            if let sessionID = sessionID {
                
                dispatch_async(dispatch_get_main_queue(), {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                })
                print("Successful login for Session \(sessionID)")
                OTMClient.sharedInstance().sessionID = sessionID
                OTMClient.sharedInstance().userID = userID
                
                OTMClient.sharedInstance().getUdacityStudentName(userID!, completionHandler: { (firstName, lastName, error) -> Void in
                    
                    if let error = error {
                        print("Error retrieving student name from Udacity: \(error)")
                    } else {
                        OTMClient.sharedInstance().firstName = firstName
                        OTMClient.sharedInstance().lastName = lastName
                    }
                    
                })
                
                self.completeLogin()
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    activityView.stopAnimating()
                    activityView.removeFromSuperview()
                })
                
                if let error = error {
                    
                    if error.localizedDescription.containsString("The Internet connection appears to be offline")  {
                        self.errorMessage = "The internet connection appears to be offline"
                    }
                    
                } else {
                    print("Login failure - no session ID or error returned")
                    self.errorMessage = "Invalid login or password"
                }
                
                let alert = UIAlertController(title: nil, message: self.errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            
        }
        
        
    }
    
    @IBAction func signup() {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        }
        
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let session = NSURLSession.sharedSession()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This function called when return key is pressed to dismiss the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}


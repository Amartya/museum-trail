//
//  ParticipantViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 2/22/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class ParticipantViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var participantInputView: UIView!
    
    
    @IBOutlet var participantInput: UITextField!
    
    //makes the keyboard disappear while tapping outside the textfield 
    //make sure that the view tapped is changed to be an instance of UIControl, instead of UIView in IB
    @IBAction func dismissKeyboard(sender: AnyObject) {
        participantInput.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this allows us to override the textFieldShouldReturn method
        self.participantInput.delegate = self
        
        //defaulting to number keyboard
        participantInput.keyboardType = UIKeyboardType.NumbersAndPunctuation
        
        if participant.participantID != -999{
            self.participantInput.text = String(participant.participantID)
        }
        
        //draw the border around the participant ID input
        Utility.drawTopAndBottomBorder(UIColor.lightGrayColor().CGColor, textField: self.participantInput)
        
        let borderColor = UIColor.init(red:0.42, green:0.569, blue:0.6, alpha:1).CGColor
        participantInputView.layer.borderColor = borderColor
        participantInputView.layer.borderWidth = 2
        participantInputView.layer.cornerRadius = 7
        participantInputView.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //this prevents a transition to the next screen if it returns false
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showRecordingScreen" || identifier == "showTrailScreen" || identifier == "showAudioTrail"{
            let initX = self.participantInput.center.x
            
            if participantInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""{
                //reset the text to show the placeholder text
                self.participantInput.text = ""
                
                //the participant id text box does a tiny shaking animation if there is no participant id provided
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.participantInput.center = CGPoint(x:initX + 10, y: self.participantInput.center.y)
                    }, completion: {(Bool)  in self.participantInput.center.x = initX})
                
                return false
            }
            
            //validating that a number was used as a participant id
            if let _ = Int(participantInput.text!){
                return true
            }
            else{
                //reset the text to show the placeholder text
                self.participantInput.text = ""
                
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.participantInput.center = CGPoint(x:initX + 10, y: self.participantInput.center.y)
                    }, completion: {(Bool)  in self.participantInput.center.x = initX})
                
                return false
            }
        
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = Int(participantInput.text!){
            participant.setIdAndDate(id, date: NSDate())
        }
    }
    
    //hides the navigation bar once the view is about to load
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
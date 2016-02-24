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
    
    @IBOutlet var participantInput: UITextField!
    
    var participant = Participant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this allows us to override the textFieldShouldReturn method
        self.participantInput.delegate = self
        
        //only allowing numeric values
        participantInput.keyboardType = UIKeyboardType.NumbersAndPunctuation
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //this prevents a transition to the next screen if it returns false
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showRecordingScreen" {
            if participantInput.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""{
                let initX = self.participantInput.center.x
                
                //reset the text to show the placeholder text
                self.participantInput.text = ""
                
                //the participant id text box does a tiny shaking animation if there is no participant id provided
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                        self.participantInput.center = CGPoint(x:initX + 10, y: self.participantInput.center.y)
                    }, completion: {(Bool)  in self.participantInput.center.x = initX})
                
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showRecordingScreen" {
            let destinationController = segue.destinationViewController as! AudioViewController
            
            
            if participantInput.text != nil && participantInput.text != "" {
                participant = Participant(participantId: Int(participantInput.text!)!, date: NSDate())
            }
            
            destinationController.participant = participant
        }
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
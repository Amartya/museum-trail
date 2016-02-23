//
//  ParticipantViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 2/22/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class ParticipantViewController: UIViewController{
    
    @IBOutlet var participantInput: UITextField!
    
    var participant = Participant()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //only allowing numeric values
        participantInput.keyboardType = UIKeyboardType.NumberPad
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
}
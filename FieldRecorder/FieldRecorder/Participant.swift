//
//  Participant.swift
//  FieldRecorder
//
//  Created by Amartya on 2/17/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation


class Participant{
    var participantID:Int
    var date:NSCalendar
    
    init(){
        self.participantID = 0
        self.date = NSCalendar.currentCalendar()
    }
}
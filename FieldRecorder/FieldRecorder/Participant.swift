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
    var date:NSDate
    
    init(){
        self.participantID = 100
        self.date = NSDate()
    }
    
    convenience init(participantId: Int, date: NSDate){
        self.init()
        self.participantID = participantId
        self.date = date
    }
}
//
//  Participant.swift
//  FieldRecorder
//
//  Created by Amartya on 2/17/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation

let participant = ParticipantModel()

//final class definition prevents sub-classing. We use the participant variable declared above as a Singleton model instance that is shared across various screens in this app
final class ParticipantModel{
    var participantID:Int
    var date:NSDate
    
    init(){
        self.participantID = -999
        self.date = NSDate()
    }
    
    convenience init(participantId: Int, date: NSDate){
        self.init()
        self.participantID = participantId
        self.date = date
    }
    
    func setIdAndDate(participantId: Int, date: NSDate){
        self.participantID = participantId
        self.date = date
    }
}
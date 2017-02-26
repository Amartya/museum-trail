//
//  InterfaceController.swift
//  Field Watch WatchKit Extension
//
//  Created by Amartya Banerjee on 2/19/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var questiontable: WKInterfaceTable!
    
    let prompts = ["Guarding against evil", "Divining the Future", "The Pig Dragon", "Shell Payments"]
    let questions = ["How did the horses ward off evil?",
                     "How did the King use Oracle Bones to talk to the dead?",
                     "What is a pig dragon",
                     "How were Cowrie shells used as currency?"]
    let imageNames = ["evilguard", "future", "pigdragon", "shellpayment"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    
        // Configure interface objects here.
        loadQuestionTable()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    

    
    func loadQuestionTable(){
        questiontable.setNumberOfRows(prompts.count, withRowType: "watchTableIdentifier")
        
        for(index, question) in prompts.enumerated(){
            let row = questiontable.rowController(at: index) as! WatchTableCell
            
            row.rowDescription.setText(question)
            row.rowIcon.setImage(UIImage(named: imageNames[index]))
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let questionData = [questions[rowIndex], imageNames[rowIndex]]
        pushController(withName: "detailquestion", context: questionData)
    }
}

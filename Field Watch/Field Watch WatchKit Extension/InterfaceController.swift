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
        let questions = ["Guarding against evil", "Divining the Future", "The Pig Dragon", "Shell Payments"]
        let imageNames = ["evilguard", "future", "pigdragon", "shellpayment"]
        
        
        questiontable.setNumberOfRows(questions.count, withRowType: "watchTableIdentifier")
        
        for(index, question) in questions.enumerated(){
            let row = questiontable.rowController(at: index) as! WatchTableCell
            
            row.rowDescription.setText(question)
            row.rowIcon.setImage(UIImage(named: imageNames[index]))
        }
    }
    
    
}

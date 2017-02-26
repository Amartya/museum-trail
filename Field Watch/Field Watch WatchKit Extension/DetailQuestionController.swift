//
//  DetailQuestionController.swift
//  Field Watch
//
//  Created by Amartya Banerjee on 2/24/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

import Foundation
import WatchKit

class DetailQuestionController:WKInterfaceController{
    
    @IBOutlet var questionImage: WKInterfaceImage!
    @IBOutlet var questionText: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let contextData = context as! [String]
        
        questionText.setText(contextData.first)
        questionImage.setImage(UIImage(named: contextData.last!))
    }
}

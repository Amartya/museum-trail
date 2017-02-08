//
//  ViewController.swift
//  FieldDay
//
//  Created by Amartya Banerjee on 1/10/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let timevalue = 6.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNotification() {
        
        let localNotification:UILocalNotification =
            UILocalNotification()
        
        localNotification.alertTitle = "Reminder"
        
        localNotification.alertBody = "Wake Up!"
        
        localNotification.fireDate = NSDate(timeIntervalSinceNow:
            timevalue) as Date
        localNotification.soundName =
        UILocalNotificationDefaultSoundName
        localNotification.category = "REMINDER_CATEGORY"
        
        UIApplication.shared.scheduleLocalNotification(
            localNotification)
    }
    
    @IBAction func buttonPress(_ sender: Any) {
        setNotification();
    }

}


//
//  ViewController.swift
//  Field Watch
//
//  Created by Amartya Banerjee on 2/19/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, ESTTriggerManagerDelegate {

    @IBOutlet var sendMessage: UIButton!
    
    let triggerManager = ESTTriggerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if(granted){
                print("granted")
            }
            else{
                print(error!)
            }
        }
        
        self.triggerManager.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendMessage(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        // Create the custom actions for the TIMER_EXPIRED category.
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION",
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let stopAction = UNNotificationAction(identifier: "STOP_ACTION",
                                              title: "Stop",
                                              options: .foreground)
        
        let expiredCategory = UNNotificationCategory(identifier: "TIMER_EXPIRED",
                                                     actions: [snoozeAction, stopAction],
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the notification categories.
        center.setNotificationCategories([generalCategory, expiredCategory])
        
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "China Hall 201", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "How did the King use Oracle Bones to talk to the dead?", arguments: nil)
        
        // Configure the trigger for a 5s delay.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2,repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "Field Alert", content: content, trigger: trigger)
        
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
}


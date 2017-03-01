//
//  ViewController.swift
//  Field Watch
//
//  Created by Amartya Banerjee on 2/19/17.
//  Copyright © 2017 Northwestern University. All rights reserved.
//

import UIKit
import UserNotifications
import WatchConnectivity

class ViewController: UIViewController, ESTTriggerManagerDelegate, WCSessionDelegate {
    @IBOutlet var sendMessage: UIButton!
    
    @IBOutlet var sendSessionMessage: UIButton!
    let triggerManager = ESTTriggerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(WCSession.isSupported()){
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        else{
            print("this device does not support apple watch communication")
        }
        
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
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session deactivated")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session inactive")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS session activation complete")
    }
    
    
    //is called if the user pairs/unpairs a watch, installs/uninstalls the watch app etc.
    func sessionWatchStateDidChange(_ session: WCSession) {
        if(!session.isPaired){
            print("could not find paired apple watch")
        }
        
        if(!session.isWatchAppInstalled){
            print("watch app not installed")
        }
//        print(session.watchDirectoryURL != nil) //watchDirectoryURL!=nil if isWatchAppInstalled is true, the watchDirectory is best used for preferences and sync states, it gets deleted when the watch app is removed/uninstalled
//        print(session.isComplicationEnabled)
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
    
    @IBAction func SendDataToWatch(_ sender: Any) {
        let session = WCSession.default()
        let message = ["watch": "artifact1"]
        
        if(session.isReachable){
            session.sendMessage(message,
                                replyHandler: {data in print("data: \(data)")},
                                errorHandler: { error in print("error: \(error)")
            })
        }
    }
}


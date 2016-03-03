//
//  Utility.swift
//  FieldRecorder
//
//  Created by Amartya on 3/3/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class Utility: UIViewController{
    static func getAppDirectoryURL() -> NSURL {
        //ask for the document directory in the user's home directory
        guard let tempDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,inDomains: NSSearchPathDomainMask.UserDomainMask).first else{
            print("Failed to get the document directory to record audio. Please try again or enable microphone access")
            return NSURL()
        }
    
        return tempDirectoryURL
    }
}
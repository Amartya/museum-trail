//
//  Utility.swift
//  FieldRecorder
//
//  Created by Amartya on 3/3/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func appendLineToURL(fileURL: NSURL) throws {
        try self.stringByAppendingString("\n").appendToURL(fileURL)
    }
    
    func appendToURL(fileURL: NSURL) throws {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        try data.appendToURL(fileURL)
    }
}

extension NSData {
    func appendToURL(fileURL: NSURL) throws {
        if let fileHandle = try? NSFileHandle(forWritingToURL: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.writeData(self)
        }
        else {
            try writeToURL(fileURL, options: .DataWritingAtomic)
        }
    }
}

class Utility: UIViewController{
    static func getAppDirectoryURL() -> NSURL {
        //ask for the document directory in the user's home directory
        guard let tempDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,inDomains: NSSearchPathDomainMask.UserDomainMask).first else{
            print("Failed to get the document directory to record audio. Please try again or enable microphone access")
            return NSURL()
        }
    
        return tempDirectoryURL
    }
    
    static func getCurrentDeviceTimestamp() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
    
        let dateCompArray = [components.hour, components.minute, components.second].flatMap { String($0) }
        
        return dateCompArray.joinWithSeparator(":")
    }
}
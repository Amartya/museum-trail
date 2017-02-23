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
    func appendLineToURL(_ fileURL: URL) throws {
        try self + "\n".appendToURL(fileURL)
    }
    
    func appendToURL(_ fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.appendToURL(fileURL)
    }
}

extension Data {
    func appendToURL(_ fileURL: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

class Utility: UIViewController{
    static func getAppDirectoryURL() -> URL {
        //ask for the document directory in the user's home directory
        guard let tempDirectoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first else{
            print("Failed to get the document directory to record audio. Please try again or enable microphone access")
            return URL()
        }
    
        return tempDirectoryURL
    }
    
    static func getCurrentDeviceTimestamp() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute, .second], from: date)
    
        let dateCompArray = [components.hour, components.minute, components.second].flatMap { String(describing: $0) }
        
        return dateCompArray.joined(separator: ":")
    }
    
    static func drawTopAndBottomBorder(_ borderColor: CGColor, textField: UITextField){
        let bottomBorder = CALayer()
        let topBorder = CALayer()
        
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: textField.frame.size.width - 1, height: 1.0)
        bottomBorder.frame = CGRect(x: 0.0, y: textField.frame.size.height - 1, width: textField.frame.size.width - 1, height: 1.0)
        
        topBorder.backgroundColor = borderColor
        bottomBorder.backgroundColor = borderColor
        
        textField.layer.addSublayer(topBorder)
        textField.layer.addSublayer(bottomBorder)
    }
}

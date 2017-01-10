//
//  EstimoteLocation.swift
//  FieldRecorder
//
//  Created by Amartya on 3/3/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation

class EstimoteLocation{
    var directoryURL: NSURL?
    var trailFileURL: NSURL?
    
    /**
     returns the list of trails in the file system in a sorted (by date desc) list
     */
    func getTrailFileName(participant:ParticipantModel) -> String {
        //figure out a default recording file path
        let calendar = NSCalendar.currentCalendar()
        let today = calendar.components([.Year, .Month, .Day], fromDate: participant.date)
        
        var fileName = String(today.year) + "-" + String(today.month) + "-" + String(today.day) + "###Participant " + String(participant.participantID) + "###Trail.txt"
        
        let allFilesNames = listTrails()!.map({ (name: NSURL) -> String in return name.lastPathComponent!})
        
        //ensuring that if there's a collision in filenames, recordings are not lost
        if allFilesNames.indexOf(fileName) != nil{
            let fileNameComponents = fileName.componentsSeparatedByString("###")
            fileName = fileNameComponents[0] + "###" + fileNameComponents[1] + "(" + NSUUID().UUIDString + ")" + "###Trail.txt"
        }
        
        return fileName
    }
    
    func listTrails() -> [NSURL]?{
        var trails: [NSURL]?
        
        do {
            //get all audio files
            var urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            urls = urls.filter( { (name: NSURL) -> Bool in return name.lastPathComponent!.hasSuffix("###Trail.txt")})
            
            //get lastModified date for each of those files
            let urlsAndDates = urls.map { url -> (NSURL, NSDate) in var lastModified : AnyObject?
                _ = try? url.getResourceValue(&lastModified, forKey: NSURLContentModificationDateKey)
                return (url, (lastModified)! as! NSDate)}
            let sortedUrlsAndDate = urlsAndDates.sort {$0.1 == $1.1 ? $0.1 > $1.1 : $0.1 > $1.1 }
            
            trails = sortedUrlsAndDate.map{url -> NSURL in return url.0}
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        catch {
            print("something went wrong listing recordings")
        }
        
        return trails
    }
}
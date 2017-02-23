//
//  EstimoteLocation.swift
//  FieldRecorder
//
//  Created by Amartya on 3/3/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation

class EstimoteLocation{
    var directoryURL: URL?
    var trailFileURL: URL?
    
    /**
     returns the list of trails in the file system in a sorted (by date desc) list
     */
    func getTrailFileName(_ participant:ParticipantModel) -> String {
        //figure out a default recording file path
        let calendar = Calendar.current
        let today = (calendar as NSCalendar).components([.year, .month, .day], from: participant.date as Date)
        
        var fileName = String(describing: today.year) + "-" + String(describing: today.month) + "-" + String(describing: today.day) + "###Participant " + String(participant.participantID) + "###Trail.txt"
        
        let allFilesNames = listTrails()!.map({ (name: URL) -> String in return name.lastPathComponent})
        
        //ensuring that if there's a collision in filenames, recordings are not lost
        if allFilesNames.index(of: fileName) != nil{
            let fileNameComponents = fileName.components(separatedBy: "###")
            fileName = fileNameComponents[0] + "###" + fileNameComponents[1] + "(" + UUID().uuidString + ")" + "###Trail.txt"
        }
        
        return fileName
    }
    
    func listTrails() -> [URL]?{
        var trails: [URL]?
        
        do {
            //get all audio files
            var urls = try FileManager.default.contentsOfDirectory(at: directoryURL!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            urls = urls.filter( { (name: URL) -> Bool in return name.lastPathComponent.hasSuffix("###Trail.txt")})
            
            //get lastModified date for each of those files
            let urlsAndDates = urls.map { url -> (URL, Date) in var lastModified : AnyObject?
                _ = try? (url as NSURL).getResourceValue(&lastModified, forKey: URLResourceKey.contentModificationDateKey)
                return (url, (lastModified)! as! Date)}
            let sortedUrlsAndDate = urlsAndDates.sorted {$0.1 == $1.1 ? $0.1 > $1.1 : $0.1 > $1.1 }
            
            trails = sortedUrlsAndDate.map{url -> URL in return url.0}
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

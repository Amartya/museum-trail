//
//  FieldFileListViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 3/7/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation


//
//  File.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/19/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class FieldFileListViewController: UITableViewController, UIPopoverControllerDelegate {
    var participant = Participant()
    
    var files:[NSURL] = []
    var selectedURL: NSURL? = NSURL()
    var selectedFileName: String = ""
    
    func parseFileNamesForDisplay() -> [String] {
        var fileNames: [String] = []
        
        for recordURL in self.files {
            fileNames.append(recordURL.lastPathComponent!)
        }
        
        return(fileNames)
    }
    
    
    // total number of rows in a section (a table view can have multiple sections but there is only one by default)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    
    //sets the icon displayed in a row to red OR b/w based on selected track
    func setTableViewIcon(indexPath: NSIndexPath, cell: AnyObject){
        var recordingCell = RecordingCell()
        var trailCell = TrailCell()
        
        if String(self.dynamicType) == "RecordListViewController"{
            recordingCell = cell as! RecordingCell
        }
        else{
            trailCell = cell as! TrailCell
        }
        
        if let _ = self.selectedURL{
            if let selectedURLIndex = self.files.indexOf(selectedURL!){
                if indexPath.row == selectedURLIndex && String(self.dynamicType) == "RecordListViewController"{
                    recordingCell.thumbnailImageView!.image = UIImage(named: "sound-icon-playing")
                }
                else if String(self.dynamicType) == "RecordListViewController"{
                    recordingCell.thumbnailImageView!.image = UIImage(named: "sound-icon")
                }
                else if indexPath.row == selectedURLIndex && String(self.dynamicType) == "TrailListViewController"{
                    trailCell.thumbnailImageView!.image = UIImage(named: "estimote")
                }
                else if String(self.dynamicType) == "TrailListViewController"{
                    trailCell.thumbnailImageView!.image = UIImage(named: "estimote")
                }
            }
        }
    }
    
    //tells the delegate that the specified row is now selected.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedURL = files[indexPath.row]
        
        let fileData = selectedURL?.lastPathComponent?.componentsSeparatedByString("###")
        if fileData!.count > 1 {
            selectedFileName = fileData![1] + " " + fileData![2]
        }
        else{
            selectedFileName = (selectedURL?.lastPathComponent)!
        }
        
        //call reload data to refresh the table view and the icon for each row (based on selection)
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            removeFileAtPath(files[indexPath.row])
            
            //remove from the array and tableview
            files.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func removeFileAtPath(fileURL: NSURL){
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(fileURL.path!)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goBackToRecorder"{
            let destinationController = segue.destinationViewController as! FullscreenAudioViewController
            destinationController.selectedAudioFileURL = selectedURL
            destinationController.selectedAudioFileLabel = selectedFileName
            
            destinationController.participant = participant
        }
        else if segue.identifier == "goBackToTrail"{
            let destinationController = segue.destinationViewController as! TrailViewController
            destinationController.participant = participant
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.rowHeight = 80.0
    }
}
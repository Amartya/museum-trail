
//
//  File.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/19/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class RecordListViewController: FieldFileListViewController {
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.selectedURL{
            shareBtn.enabled = true
        }
        else{
            shareBtn.enabled = false
        }
    }

    @IBAction func airDrop(sender: AnyObject) {
        let airDropController = UIActivityViewController.init(activityItems: [self.selectedURL!], applicationActivities: nil)
        self.presentViewController(airDropController, animated: true, completion: nil)
    }
    
    //This method will be called every time a table row is displayed. By using the indexPath object, we can get the current row ( indexPath.row ).
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellIdentifier = "recordingCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! RecordingCell
        
        let fileData = self.parseFileNamesForDisplay()[indexPath.row].componentsSeparatedByString("###")
        
        if fileData.count > 1 {
            cell.dateLabel.text = fileData[0]
            cell.participantLabel.text = fileData[1]
            cell.fileNameLabel.text = fileData[1] + " " + fileData[2]
        }
        else{
            cell.dateLabel.text = fileData.joinWithSeparator("")
            cell.participantLabel.text = fileData.joinWithSeparator("")
            cell.fileNameLabel.text = fileData.joinWithSeparator("")
        }
        
        self.setTableViewIcon(indexPath, cell:cell)
        
        return cell
    }

    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.removeFileAtPath(self.files[indexPath.row])
            
            //remove from the array and tableview
            self.files.removeAtIndex(indexPath.row)
            tableView.reloadData()
            
            //disable the share button if all the files are deleted
            if self.files.count == 0 {
                shareBtn.enabled = false
            }
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
    }
}
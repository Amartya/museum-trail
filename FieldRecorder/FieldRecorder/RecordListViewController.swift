
//
//  File.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/19/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class RecordListViewController: UITableViewController, UIPopoverControllerDelegate {
    var participant = Participant()
    
    var recordFiles:[NSURL] = []
    var selectedURL: NSURL? = NSURL()
    var selectedFileName: String = ""
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    func parseRecordingNamesForDisplay() -> [String] {
        var recordFileNames: [String] = []
        
        for recordURL in self.recordFiles {
            recordFileNames.append(recordURL.lastPathComponent!)
        }
        
        return(recordFileNames)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.selectedURL{
            shareBtn.enabled = true
        }
        else{
            shareBtn.enabled = false
        }
    }
    
    // total number of rows in a section (a table view can have multiple sections but there is only one by default)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordFiles.count
    }
    
    @IBAction func airDrop(sender: AnyObject) {
        let airDropController = UIActivityViewController.init(activityItems: [self.selectedURL!], applicationActivities: nil)
        self.presentViewController(airDropController, animated: true, completion: nil)
    }
    
    //This method will be called every time a table row is displayed. By using the indexPath object, we can get the current row ( indexPath.row ).
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! Recording
        
        let fileData = parseRecordingNamesForDisplay()[indexPath.row].componentsSeparatedByString("###")
        
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
        
        setSoundIcon(indexPath, cell:cell)
        
        return cell
    }
    
    //sets the icon displayed in a row to red OR b/w based on selected track
    func setSoundIcon(indexPath: NSIndexPath, cell: Recording){
        
        if let _ = self.selectedURL{
            if let selectedURLIndex = self.recordFiles.indexOf(selectedURL!){
                if indexPath.row == selectedURLIndex{
                    cell.thumbnailImageView!.image = UIImage(named: "sound-icon-playing")
                }
                else{
                    cell.thumbnailImageView!.image = UIImage(named: "sound-icon")
                }
            }
        }
    }
    
    //tells the delegate that the specified row is now selected.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedURL = recordFiles[indexPath.row]
        
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
            
            //remove the file from the app's directory
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtPath(recordFiles[indexPath.row].path!)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
            //remove from the array and tableview
            recordFiles.removeAtIndex(indexPath.row)
            tableView.reloadData()
            
            //disable the share button if all the files are deleted
            if recordFiles.count == 0 {
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
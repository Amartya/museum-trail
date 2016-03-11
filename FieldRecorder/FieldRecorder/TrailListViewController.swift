//
//  TrailListViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 3/8/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation


class TrailListViewController: FieldFileListViewController{
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
    
    //This method will be called every time a table row is displayed. By using the indexPath object, we can get the current row ( indexPath.row ).
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellIdentifier = "trailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! TrailCell
        
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
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       //
    }
}
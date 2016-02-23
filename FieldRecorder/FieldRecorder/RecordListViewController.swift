
//
//  File.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/19/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class RecordListViewController: UITableViewController {
    
    var recordFiles:[NSURL] = []
    
    func parseRecordingNamesForDisplay() -> [String] {
        var recordFileNames: [String] = []
        
        for recordURL in self.recordFiles {
            recordFileNames.append(recordURL.lastPathComponent!)
        }
        
        return(recordFileNames)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // total number of rows in a section (a table view can have multiple sections but there is only one by default)
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordFiles.count
    }
    
    //This method will be called every time a table row is displayed. By using the indexPath object, we can get the current row ( indexPath.row ).
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! Recording
        
        let fileData = parseRecordingNamesForDisplay()[indexPath.row].componentsSeparatedByString("###")
        
        if fileData.count > 1 {
            cell.dateLabel.text = fileData[0]
            cell.participantLabel.text = fileData[1]
            cell.fileNameLabel.text = fileData.joinWithSeparator("")
        }
        else{
            cell.dateLabel.text = fileData.joinWithSeparator("")
            cell.participantLabel.text = fileData.joinWithSeparator("")
            cell.fileNameLabel.text = fileData.joinWithSeparator("")
        }
        
        //cell.participantLabel.text = fileData.componentsSeparatedByString("###")
        //fill the cell data
//        cell.textLabel?.text = parseRecordingNamesForDisplay()[indexPath.row]
//        cell.imageView?.image = UIImage(named: "sound-icon")
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
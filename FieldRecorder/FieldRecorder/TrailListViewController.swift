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
    
    //This method will be called every time a table row is displayed. By using the indexPath object, we can get the current row ( indexPath.row ).
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cellIdentifier = "trailCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,forIndexPath: indexPath) as! Recording
        
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
}
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
    var files:[URL] = []
    var selectedURL: URL? = URL(string: "")
    var selectedFileName: String = ""
    
    func parseFileNamesForDisplay() -> [String] {
        var fileNames: [String] = []
        
        for recordURL in self.files {
            fileNames.append(recordURL.lastPathComponent)
        }
        
        return(fileNames)
    }
    
    
    // total number of rows in a section (a table view can have multiple sections but there is only one by default)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    //sets the icon displayed in a row to red OR b/w based on selected track
    func setTableViewIcon(_ indexPath: IndexPath, cell: AnyObject){
        var recordingCell = RecordingCell()
        var trailCell = TrailCell()
        
        if String(describing: type(of: self)) == "RecordListViewController"{
            recordingCell = cell as! RecordingCell
        }
        else{
            trailCell = cell as! TrailCell
        }
        
        if let _ = self.selectedURL{
            if let selectedURLIndex = self.files.index(of: selectedURL!){
                if indexPath.row == selectedURLIndex && String(describing: type(of: self)) == "RecordListViewController"{
                    recordingCell.thumbnailImageView!.image = UIImage(named: "sound-icon-playing")
                }
                else if String(describing: type(of: self)) == "RecordListViewController"{
                    recordingCell.thumbnailImageView!.image = UIImage(named: "sound-icon")
                }
                else if indexPath.row == selectedURLIndex && String(describing: type(of: self)) == "TrailListViewController"{
                    trailCell.thumbnailImageView!.image = UIImage(named: "estimote-selected")
                }
                else if String(describing: type(of: self)) == "TrailListViewController"{
                    trailCell.thumbnailImageView!.image = UIImage(named: "estimote")
                }
            }
        }
    }
    
    //tells the delegate that the specified row is now selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedURL = files[indexPath.row]
        
        let fileData = selectedURL?.lastPathComponent.components(separatedBy: "###")
        if fileData!.count > 1 {
            selectedFileName = fileData![1] + " " + fileData![2]
        }
        else{
            selectedFileName = (selectedURL?.lastPathComponent)!
        }
        
        //call reload data to refresh the table view and the icon for each row (based on selection)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            removeFileAtPath(files[indexPath.row])
            
            //remove from the array and tableview
            files.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func removeFileAtPath(_ fileURL: URL){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: fileURL.path)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    
    //hides the status bar
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goBackToRecorder"{
            let destinationController = segue.destination as! FullscreenAudioViewController
            destinationController.selectedAudioFileURL = selectedURL
            destinationController.selectedAudioFileLabel = selectedFileName
        }
    }
    
    override func viewDidLoad() {
        self.tableView.rowHeight = 80.0
    }
}

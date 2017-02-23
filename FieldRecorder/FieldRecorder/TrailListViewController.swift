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
            shareBtn.isEnabled = true
        }
        else{
            shareBtn.isEnabled = false
        }
    }
    
    @IBAction func airDrop(_ sender: AnyObject) {
        let airDropController = UIActivityViewController.init(activityItems: [self.selectedURL!], applicationActivities: nil)
        self.present(airDropController, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            self.removeFileAtPath(self.files[indexPath.row])
            
            //remove from the array and tableview
            self.files.remove(at: indexPath.row)
            tableView.reloadData()
            
            //disable the share button if all the files are deleted
            if self.files.count == 0 {
                shareBtn.isEnabled = false
            }
        }
    }
    
    //This method will be called every time a table row is displayed. By using the indexPath object, we can get the current row ( indexPath.row ).
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cellIdentifier = "trailCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! TrailCell
        
        let fileData = self.parseFileNamesForDisplay()[indexPath.row].components(separatedBy: "###")
        
        if fileData.count > 1 {
            cell.dateLabel.text = fileData[0]
            cell.participantLabel.text = fileData[1]
            cell.fileNameLabel.text = fileData[1] + " " + fileData[2]
        }
        else{
            cell.dateLabel.text = fileData.joined(separator: "")
            cell.participantLabel.text = fileData.joined(separator: "")
            cell.fileNameLabel.text = fileData.joined(separator: "")
        }
        
        self.setTableViewIcon(indexPath, cell:cell)
        
        return cell
    }
    
    //hides the status bar
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       //
    }
}

//
//  Recording.swift
//  FieldRecorder
//
//  Created by Amartya on 2/22/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

//TODO use this protocol to reduce code duplication for table cells
protocol FieldTableCell {
    var participantLabel: UILabel { get set }
    var dateLabel: UILabel { get set }
    var fileNameLabel: UILabel { get set }
    var thumbnailImageView: UIImageView{ get set}
}

class RecordingCell: UITableViewCell{
    @IBOutlet var participantLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    
    static func recordingURLtoFileName(_ url: URL) -> String?{
        let fileData = url.lastPathComponent.components(separatedBy: "###")
        
        var fileName = ""
        if fileData.count >= 2{
            fileName = fileData[1] + fileData[2]
        }
        
        return fileName
    }
    
    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
}

class TrailCell: UITableViewCell{
    @IBOutlet var participantLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    
    static func trailURLtoFileName(_ url: URL) -> String?{
        let fileData = url.lastPathComponent.components(separatedBy: "###")
        
        var fileName = ""
        if fileData.count >= 2{
            fileName = fileData[1] + fileData[2]
        }
        
        return fileName
    }
    
    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
}

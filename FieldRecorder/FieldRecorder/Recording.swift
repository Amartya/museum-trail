//
//  Recording.swift
//  FieldRecorder
//
//  Created by Amartya on 2/22/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import UIKit

class Recording: UITableViewCell{
    @IBOutlet var participantLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    
    static func recordingURLtoFileName(url: NSURL) -> String?{
        let fileData = url.lastPathComponent?.componentsSeparatedByString("###")
        
        var fileName = ""
        if fileData!.count >= 2{
            fileName = fileData![1] + fileData![2]
        }
        
        return fileName
    }
}
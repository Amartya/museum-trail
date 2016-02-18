//
//  Audio.swift
//  FieldRecorder
//
//  Created by Amartya on 2/17/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import UIKit
import AVFoundation

let RECORDERSETTINGS = [
    AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatAppleLossless),
    AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
    AVEncoderBitRateKey : 320000,
    AVNumberOfChannelsKey: 2,
    AVSampleRateKey : 44100.0
]

class FieldAudio  {
    var player: AVAudioPlayer!
    var recorder: AVAudioRecorder!
    var recordFileURL: NSURL!
    
    init() {
        //get the path of our file
        let filePathString = NSBundle.mainBundle().pathForResource("instrumental", ofType: "mp3")
        
        if let filePathString = filePathString{
            let filePathURL = NSURL(fileURLWithPath: filePathString)
            
            do {
                try player = AVAudioPlayer(contentsOfURL: filePathURL)
            }
            catch{
                print("Error reading file")
            }
        }
    }
    
    func setupRecorder(){
        let recordedAudioFileName = "recording-\(NSDate()).m4a"
        print(recordedAudioFileName)
        
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        recordFileURL = documentsDirectory.URLByAppendingPathComponent(recordedAudioFileName)
        
        do{
            try recorder = AVAudioRecorder(URL: recordFileURL, settings: RECORDERSETTINGS)
            recorder.meteringEnabled = true
            recorder.prepareToRecord()
        }
        catch let error as NSError{
            recorder = nil
            print("Unable to initialize recording" + error.localizedDescription)
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func playRecord() {
        var url:NSURL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.recordFileURL!
        }
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url!)
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
}
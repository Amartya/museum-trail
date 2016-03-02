//
//  Audio.swift
//  FieldRecorder
//
//  Created by Amartya on 2/29/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import AVFoundation

class Audio: UIViewController{
    var directoryURL: NSURL?
    var audioFileURL: NSURL?
    var recordingSettings: [String: AnyObject]?
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    var audioCurrentTime: NSTimeInterval?
    
    func getAudioFileName(participant:Participant) -> String {
        //figure out a default recording file path
        let calendar = NSCalendar.currentCalendar()
        let today = calendar.components([.Year, .Month, .Day], fromDate: participant.date)
        
        var fileName = String(today.year) + "-" + String(today.month) + "-" + String(today.day) + "###Participant " + String(participant.participantID) + "###Audio.m4a"
        
        let allFilesNames = listRecordings()!.map({ (name: NSURL) -> String in return name.lastPathComponent!})
        
        //ensuring that if there's a collision in filenames, recordings are not lost
        if allFilesNames.indexOf(fileName) != nil{
            let fileNameComponents = fileName.componentsSeparatedByString("###")
            fileName = fileNameComponents[0] + "###" + fileNameComponents[1] + "(" + NSUUID().UUIDString + ")" + "###Audio.m4a"
        }
        
        return fileName
    }
    
    /**
     returns the list of recordings in the file system in a sorted (by date desc) list
     */
    func listRecordings() -> [NSURL]?{
        var recordings: [NSURL]?
        
        do {
            //get all audio files
            var urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            urls = urls.filter( { (name: NSURL) -> Bool in return name.lastPathComponent!.hasSuffix("###Audio.m4a")})
            
            //get lastModified date for each of those files
            let urlsAndDates = urls.map { url -> (NSURL, NSDate) in var lastModified : AnyObject?
                _ = try? url.getResourceValue(&lastModified, forKey: NSURLContentModificationDateKey)
                return (url, (lastModified)! as! NSDate)}
            let sortedUrlsAndDate = urlsAndDates.sort {$0.1 == $1.1 ? $0.1 > $1.1 : $0.1 > $1.1 }
            
            recordings = sortedUrlsAndDate.map{url -> NSURL in return url.0}
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        catch {
            print("something went wrong listing recordings")
        }
        
        return recordings
    }
    
    
    /**iOS handles audio behavior of an app by using audio sessions. It acts as a middle man between your app and the system's media service.
     Through the shared audio session object, you tell the system how you're going to use audio in your app.
     The audio session provides answers to questions like: Should the system disable the existing music being played by the Music app?
     Should your app be allowed to record audio and music playback?
     */
    func setupRecorder() -> AVAudioSession{
        let audioSession = AVAudioSession.sharedInstance()
        
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            
            //initialize and prep the recorder
            audioRecorder = try AVAudioRecorder(URL:audioFileURL!, settings: recordingSettings!)
            audioRecorder?.meteringEnabled = true
            //audioRecorder?.prepareToRecord()
            
        } catch{
            print(error)
        }
        return audioSession
    }
    
    /**
     to play audio, we need the following
     1. initialize the audio player and assign a sound file to it.
     2. designate an audio player delegate object, which handles interruptions as well as the playback-completed event.
     3. call the play method to play the sound file.
     */
    func playAudio(){
        if let audioRecorder = audioRecorder {
            if !audioRecorder.recording {
                do{
                    if let selectedToPlay = self.audioFileURL {
                        try audioPlayer = AVAudioPlayer(contentsOfURL: selectedToPlay)
                        audioPlayer?.meteringEnabled = true
                        
                        audioPlayer?.play()
                    }
                    
                }
                catch{
                    let alertMessage = UIAlertController(title: "Field Audio Player", message:"Issue finding or playing audio file, try a different recording using the list recording option", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    presentViewController(alertMessage, animated: true, completion: nil)
                }
            }
        }
    }
    
    func toggleRecording(){
        //stop the audio player if it's currently playing
        if let player = audioPlayer{
            if player.playing{
                player.stop()
            }
        }
        
        if let recorder = self.audioRecorder{
            if !recorder.recording {
                let audioSession = AVAudioSession.sharedInstance()
                
                do{
                    try audioSession.setActive(true)
                    
                    //begin recording
                    recorder.record()
                }
                catch{
                    print(error)
                }
            }
            else{
                recorder.pause()
            }
        }
    }
    
    func stopRecording(){
        audioRecorder?.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setActive(false)
        }
        catch{
            print(error)
        }
    }
    
    func pausePlayer(){
        if let _ = audioPlayer{
            audioPlayer?.pause()
            audioCurrentTime = audioPlayer!.currentTime
        }
    }
    
    func adjustVolume(volume: Float){
        if let _ = audioPlayer{
            audioPlayer?.volume = volume
        }
    }
}
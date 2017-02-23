//
//  Audio.swift
//  FieldRecorder
//
//  Created by Amartya on 2/29/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import AVFoundation

/** to record audio, we need the following
 1. specify a sound file URL
 2. setup a shared audio session
 3. configure the audio recorder's init state (recording format, bitrate etc.)
 */
class Audio: UIViewController{
    var directoryURL: URL?
    var audioFileURL: URL?
    var recordingSettings: [String: AnyObject]?
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    var audioCurrentTime: TimeInterval?
    
    func getAudioFileName(_ participant:ParticipantModel) -> String {
        //figure out a default recording file path
        let calendar = Calendar.current
        let today = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: participant.date as Date)
        
        var fileName = String(describing: today.year) + "-" + String(describing: today.month) + "-" + String(describing: today.day) + "-" + String(describing: today.hour) + ":" + String(describing: today.minute) + ":" + String(describing: today.second) + "###Participant " + String(participant.participantID) + "###Audio.m4a"
        
        let allFilesNames = listRecordings()!.map({ (name: URL) -> String in return name.lastPathComponent})
        
        //ensuring that if there's a collision in filenames, recordings are not lost
        if allFilesNames.index(of: fileName) != nil{
            let fileNameComponents = fileName.components(separatedBy: "###")
            fileName = fileNameComponents[0] + "###" + fileNameComponents[1] + "(" + UUID().uuidString + ")" + "###Audio.m4a"
        }
        
        return fileName
    }
    
    /**
     returns the list of recordings in the file system in a sorted (by date desc) list
     */
    func listRecordings() -> [URL]?{
        var recordings: [URL]?
        
        do {
            //get all audio files
            var urls = try FileManager.default.contentsOfDirectory(at: directoryURL!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            urls = urls.filter( { (name: URL) -> Bool in return name.lastPathComponent.hasSuffix("###Audio.m4a")})
            
            //get lastModified date for each of those files
            let urlsAndDates = urls.map { url -> (URL, Date) in var lastModified : AnyObject?
                _ = try? (url as NSURL).getResourceValue(&lastModified, forKey: URLResourceKey.contentModificationDateKey)
                return (url, (lastModified)! as! Date)}
            let sortedUrlsAndDate = urlsAndDates.sorted {$0.1 == $1.1 ? $0.1 > $1.1 : $0.1 > $1.1 }
            
            recordings = sortedUrlsAndDate.map{url -> URL in return url.0}
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
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            
            //initialize and prep the recorder
            audioRecorder = try AVAudioRecorder(url:audioFileURL!, settings: recordingSettings!)
            audioRecorder?.isMeteringEnabled = true
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
        if let player = audioPlayer{
            if !player.isPlaying{
                player.play()
            }
        }
        else{
            do{
                if let selectedToPlay = self.audioFileURL {
                    try audioPlayer = AVAudioPlayer(contentsOf: selectedToPlay)
                    audioPlayer?.isMeteringEnabled = true
                    
                    audioPlayer?.play()
                }
            }
            catch{
                let alertMessage = UIAlertController(title: "Field Audio Player", message:"Issue finding or playing audio file, try a different recording using the list recording option", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                present(alertMessage, animated: true, completion: nil)
            }
        }
    }
    
    
    func toggleRecording(){
        //stop the audio player if it's currently playing
        if let player = audioPlayer{
            if player.isPlaying{
                player.stop()
            }
        }
        
        if let recorder = self.audioRecorder{
            if !recorder.isRecording {
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
    
    func adjustVolume(_ volume: Float){
        if let _ = audioPlayer{
            audioPlayer?.volume = volume
        }
    }
}

//
//  Audio.swift
//  FieldRecorder
//
//  Created by Amartya on 2/29/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import AVFoundation

class Audio: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var audioFileURL: NSURL?
    var recordingSettings: [String: AnyObject]?
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    
    
    func setupRecorder() -> AVAudioSession{
        let audioSession = AVAudioSession.sharedInstance()
        
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            
            //initialize and prep the recorder
            audioRecorder = try AVAudioRecorder(URL:audioFileURL!, settings: recordingSettings!)
            audioRecorder?.delegate = self.audioRecorder?.delegate
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
            
        } catch{
            print(error)
        }
        return audioSession
    }
    
    
    func playAudio(alertTitle: String = "", alertMessage: String = ""){
        if let audioRecorder = audioRecorder {
            if !audioRecorder.recording {
                do{
                    if let selectedToPlay = self.audioFileURL {
                        try audioPlayer = AVAudioPlayer(contentsOfURL: selectedToPlay)
                        audioPlayer?.delegate = self.audioPlayer?.delegate
                        audioPlayer?.meteringEnabled = true
                        audioPlayer?.play()
                    }
                }
                catch{
                    let alertMessage = UIAlertController(title: alertTitle, message:alertMessage, preferredStyle: .Alert)
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
    
    func pausePlayer(){
        if let _ = audioPlayer{
            audioPlayer?.pause()        }
    }
    
    func adjustVolume(volume: Float){
        if let _ = audioPlayer{
            audioPlayer?.volume = volume
        }
    }
}
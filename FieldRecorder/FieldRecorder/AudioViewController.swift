//
//  AudioViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 2/17/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import AVFoundation
import UIKit

/***
 AVAudioRecorder makes use of the delegate design pattern. We can implement a delegate object 
 for an audio recorder to respond to audio interruptions & to the completion of a recording
 Similarly, the AVAudioplayerDelegate protocol allows one to handle interruptions, audio decoding errors, 
 and update the user interface when an audio file finishes playing. 
 */

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var directoryURL: NSURL?
    var audioRecorderURL: NSURL?
    var recordings: [NSURL]? = []
    
    /** to record audio, we need the following
        1. specify a sound file URL
        2. setup a shared audio session
        3. configure the audio recorder's init state (recording format, bitrate etc.)
    */
    
    let recordingSettings: [String: AnyObject] =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var volumeLevel: UISlider!
    
    @IBAction func stop(sender: UIButton) {
        //reset the recording button
        recordButton.setImage(UIImage(named: "record"), forState: UIControlState.Normal)
        recordButton.selected = false
        
        //reset the play button
        playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        playButton.selected = false
        playButton.enabled = true
        
        stopButton.enabled = false
        volumeLevel.enabled = true
        
        audioRecorder?.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setActive(false)
        }
        catch{
            print(error)
        }
    }
    
    /**
     to play audio, we need the following
     1. initialize the audio player and assign a sound file to it.
     2. designate an audio player delegate object, which handles interruptions as well as the playback-completed event.
     3. call the play method to play the sound file.
     */
    @IBAction func playRecording(sender: UIButton) {
        if let recorder = audioRecorder {
            if !recorder.recording {
                do{
                    volumeLevel.enabled = true
            
                    listRecordings()
                    
                    if let recordingToPlay = recordings!.last{
                        try audioPlayer = AVAudioPlayer(contentsOfURL: recordingToPlay)
                        audioPlayer?.delegate = self
                        audioPlayer?.volume = volumeLevel.value
                        audioPlayer?.play()
                        playButton.selected = true
                    }
                    else{
                        print(recordings)
                    }
                }
                catch{
                    let alertMessage = UIAlertController(title: "No Recordings", message:"No recordings are available!", preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                    presentViewController(alertMessage, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func toggleRecording(sender: UIButton) {
        //stop the audio player if it's currently playing
        if let player = audioPlayer{
            if player.playing{
                player.stop()
                playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
                playButton.selected = false
            }
        }
        
        audioRecorderURL = directoryURL!.URLByAppendingPathComponent("FieldMemo" + String(NSDate()) + ".m4a")
        let audioSession = setupRecorder()
        
        if let recorder = audioRecorder{
            if !recorder.recording {
                do{
                    try audioSession.setActive(true)
            
                    //begin recording
                    recorder.record()
                    recordButton.setImage(UIImage(named: "stoprecording"), forState: UIControlState.Normal)
                    recordButton.selected = false
                    
                    //store recording url
                    recordings?.append(audioRecorderURL!)                }
                catch{
                    print(error)
                }
            }
            else{
                recorder.pause()
                recordButton.setImage(UIImage(named: "record"), forState: UIControlState.Normal)
                recordButton.selected = false
            }
        }
        stopButton.enabled = true
        playButton.enabled = false
        volumeLevel.enabled = false
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        if let _ = audioPlayer{
            audioPlayer?.volume = sender.value
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the buttons to be deactivated initially
        stopButton.enabled = false
        playButton.enabled = false
        volumeLevel.enabled = false
        
        //ask for the document directory in the user's home directory
        guard let tempDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory,inDomains: NSSearchPathDomainMask.UserDomainMask).first else{
            
            let alertMessage = UIAlertController(title: "Recording Failed", message: "Failed to get the document directory to record audio. Please try again or enable microphone access", preferredStyle: .Alert)
            
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            
            return
        }
        directoryURL = tempDirectoryURL
    }
    
    func listRecordings() -> [NSURL]{
        do {
            let urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            self.recordings = urls.filter( { (name: NSURL) -> Bool in return name.lastPathComponent!.hasSuffix("m4a")})
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        catch {
            print("something went wrong listing recordings")
        }
        return self.recordings!
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
            audioRecorder = try AVAudioRecorder(URL:audioRecorderURL!, settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            //finally add the url to the audio recording urls array
            recordings?.append(audioRecorderURL!)
            
        } catch{
            print(error)
        }
        return audioSession
    }
    
    
    //part of the AVAudioRecorderDelegate protocol, but this is an optional. Using this to inform that we successfully recorded the audio
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            let alertMessage = UIAlertController(title: "Finished Recording", message: "Successfully recorded audio!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    //part of the AVAudioPlayerDelegate protocol, but this is an optional as well.
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag:Bool) {
            playButton.selected = false
            let alertMessage = UIAlertController(title: "Finish Playing", message:"Finished playing the recording!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAllRecordings"{
            let destinationController = segue.destinationViewController as! RecordListViewController
            destinationController.recordFiles = listRecordings()
        }
    }
}
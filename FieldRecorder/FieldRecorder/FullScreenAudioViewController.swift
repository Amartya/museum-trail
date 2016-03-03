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

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

class FullscreenAudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var fieldAudio = Audio()
    
    var directoryURL: NSURL?
    var recordings: [NSURL]? = []
    var participant = Participant()
    
    var selectedAudioFileURL: NSURL?
    var selectedAudioFileLabel: String = ""
    
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    /** to record audio, we need the following
        1. specify a sound file URL
        2. setup a shared audio session
        3. configure the audio recorder's init state (recording format, bitrate etc.)
    */
    let recordingSettings: [String: AnyObject] =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 16000.0,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]

    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var volumeLevel: UISlider!
    
    @IBOutlet var currentlySelectedLabel: UILabel!
    
    @IBAction func stop(sender: UIButton) {
        fieldAudio.stopRecording()
        
        //reset the recording button
        recordButton.setImage(UIImage(named: "record"), forState: UIControlState.Normal)
        recordButton.selected = false
        
        //reset the play button
        playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        playButton.selected = false
        playButton.enabled = true
        
        stopButton.enabled = false
        volumeLevel.enabled = true
    }
    

    @IBAction func playRecording(sender: UIButton) {
        if let audioPlayer = fieldAudio.audioPlayer {
            if(audioPlayer.playing){
                fieldAudio.pausePlayer()
                playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
                resetAudioVisualizer()
            }
            else if let currentTime = fieldAudio.audioCurrentTime{
                fieldAudio.audioPlayer?.playAtTime(currentTime)
                playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
            }
        }
        else{
        fieldAudio.audioPlayer?.delegate = self
            fieldAudio.playAudio()
            playButton.setImage(UIImage(named: "pause"), forState: UIControlState.Normal)
        }

        fieldAudio.audioPlayer?.delegate = self
    }
    

    @IBAction func toggleRecording(sender: UIButton) {
        //stop the audio player if it's currently playing
        if let player = fieldAudio.audioPlayer{
            if player.playing{
                player.stop()
                playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
                playButton.selected = false
            }
        }
        
        //ensure that the playbutton is disabled and the file name is changed to the participant id for which the recording is being done
        currentlySelectedLabel?.text = "Participant " + String(participant.participantID) + " Audio.m4a"
        playButton.enabled = false
        
        setupRecorder()
        
        fieldAudio.toggleRecording()
        
        fieldAudio.audioRecorder?.delegate = self
        
        stopButton.enabled = true
        volumeLevel.enabled = false
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        fieldAudio.adjustVolume(sender.value)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        //set the buttons to be deactivated initially
        stopButton.enabled = false
        playButton.enabled = false
        volumeLevel.enabled = false
        
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        setAudioFileLabel() 
        
        //using the timer to read the input levels for the sound
        var _ = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    // must be internal or public.
    func update() {
        if let audioPlayer = fieldAudio.audioPlayer{
            if audioPlayer.playing{
                var power: Double = 0.0;
            
                audioPlayer.updateMeters()
            
                for i in 0..<audioPlayer.numberOfChannels{
                    power += Double(audioPlayer.averagePowerForChannel(i))
                    power /= Double(audioPlayer.numberOfChannels)
                }
            
                updateVisualizer(power, playing: true)
            }
        }
        
        if let audioRecorder = fieldAudio.audioRecorder{
            if audioRecorder.recording{
                var power: Double = 0.0;
            
                audioRecorder.updateMeters()
                let audioRecorderTemp = audioRecorder

                for i in 0..<2{
                    power += Double(audioRecorderTemp.averagePowerForChannel(i))
                    power /= Double(2)
                }
            updateVisualizer(power, recording: true)
            }
        }   
    }
    
    func updateVisualizer(power: Double, playing: Bool = false, recording: Bool = false){
        let scale = CGFloat(AudioVisualizer.scale(power, baseMin: -150, baseMax: 0, limitMin: 0, limitMax: 1))
        let radius = scale * 200
        let center = CGPoint(x:audioVisualizer.bounds.width/2 + audioVisualizer.bounds.origin.x,
            y:audioVisualizer.bounds.height/2 + audioVisualizer.bounds.origin.y)
        
        audioVisualizer.rect = CGRect(x: center.x - radius/2, y: center.y - radius/2,
            width: radius, height: radius)
        
        
        if playing{
            audioVisualizer.color = UIColor(red: scale, green: 0.5, blue: max(2*scale,1), alpha: 1.0)
        }
        else if recording{
            audioVisualizer.color = UIColor(red: 0.25, green: scale, blue: max(2*scale,1), alpha: 1.0)
        }
        
        audioVisualizer.setNeedsDisplay()
    }
    
    func resetAudioVisualizer(){
        let center = CGPoint(x:audioVisualizer.bounds.width/2 + audioVisualizer.bounds.origin.x,
            y:audioVisualizer.bounds.height/2 + audioVisualizer.bounds.origin.y)
        audioVisualizer.rect = CGRect(x: center.x, y: center.y ,width: 0, height: 0)
        audioVisualizer.setNeedsDisplay()
    }
    
    func setupRecorder(){
        //set the recorder's settings
        fieldAudio.recordingSettings = recordingSettings
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        fieldAudio.audioFileURL = fieldAudio.directoryURL!.URLByAppendingPathComponent(fieldAudio.getAudioFileName(self.participant))
        
        //the recorder can be setup after the file url and the recording settings have been assigned
        fieldAudio.setupRecorder()
    }
    
    func setAudioFileLabel() {
        let tempRecordings = fieldAudio.listRecordings()!
        
        if(tempRecordings.count > 0){
            if selectedAudioFileLabel.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                currentlySelectedLabel?.text = "Participant " + String(participant.participantID) + " Audio.m4a"
                playButton.enabled = false
            }
            else{
                currentlySelectedLabel?.text = selectedAudioFileLabel
                playButton.enabled = true
            }
        }
        else{
            currentlySelectedLabel?.text?.removeAll()
        }
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    //part of the AVAudioRecorderDelegate protocol, but this is an optional. Using this to inform that we successfully recorded the audio
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        fieldAudio.audioRecorder?.stop()
        
        if flag{
            let alertMessage = UIAlertController(title: "Finished Recording", message: "Successfully recorded audio!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            resetAudioVisualizer()
        }
    }
    
    //part of the AVAudioPlayerDelegate protocol, but this is an optional as well.
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            let alertMessage = UIAlertController(title: "Finish Playing", message:"Finished playing the recording!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            presentViewController(alertMessage, animated: true, completion: nil)

            playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
            resetAudioVisualizer()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
            case "showAllRecordings":
                let navController = segue.destinationViewController as! UINavigationController
                let destinationController = navController.viewControllers.first as! RecordListViewController
                let allRecordings = fieldAudio.listRecordings()!
                
                destinationController.recordFiles = allRecordings
                if allRecordings.count > 0{
                    destinationController.selectedURL = allRecordings.first!
                }
                
                //store the participant id across screens
                destinationController.participant = self.participant
            
            case "showParticipantScreen":
                let destinationController = segue.destinationViewController as! ParticipantViewController
                destinationController.participant = self.participant
            
            default:
                print("unreachable segue detected")
        }
    }
}
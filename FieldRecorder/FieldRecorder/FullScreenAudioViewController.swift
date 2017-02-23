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

public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .orderedSame
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

extension Date: Comparable { }

class FullscreenAudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var fieldAudio = Audio()
    
    var directoryURL: URL?
    var recordings: [URL]? = []
    
    var selectedAudioFileURL: URL?
    var selectedAudioFileLabel: String = ""
    
    var timer = Timer()
    
    @IBOutlet weak var audioVisualizer: AudioVisualizer!

    let recordingSettings: [String: AnyObject] =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject,
        AVSampleRateKey: 16000.0 as AnyObject,
        AVNumberOfChannelsKey: 2 as AnyObject,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue as AnyObject
    ]

    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var volumeLevel: UISlider!
    
    @IBOutlet var currentlySelectedLabel: UILabel!
    
    @IBAction func stop(_ sender: UIButton) {
        fieldAudio.stopRecording()
        
        //reset the recording button
        recordButton.setImage(UIImage(named: "record"), for: UIControlState())
        recordButton.isSelected = false
        
        //reset the play button
        playButton.setImage(UIImage(named: "play"), for: UIControlState())
        playButton.isSelected = false
        playButton.isEnabled = true
        
        stopButton.isEnabled = false
        volumeLevel.isEnabled = true
    }
    

    @IBAction func playRecording(_ sender: UIButton) {
        if let audioPlayer = fieldAudio.audioPlayer {
            if(audioPlayer.isPlaying){
                fieldAudio.pausePlayer()
                playButton.setImage(UIImage(named: "play"), for: UIControlState())
                resetAudioVisualizer()
            }
            else{
                fieldAudio.playAudio()
                playButton.setImage(UIImage(named: "pause"), for: UIControlState())
            }
        }
        else{
            fieldAudio.playAudio()
            playButton.setImage(UIImage(named: "pause"), for: UIControlState())
        }

        fieldAudio.audioPlayer?.delegate = self
    }
    

    @IBAction func toggleRecording(_ sender: UIButton) {
        //stop the audio player if it's currently playing
        if let player = fieldAudio.audioPlayer{
            if player.isPlaying{
                player.stop()
                playButton.setImage(UIImage(named: "play"), for: UIControlState())
                playButton.isSelected = false
            }
        }
        
        //ensure that the playbutton is disabled and the file name is changed to the participant id for which the recording is being done
        currentlySelectedLabel?.text = "Participant " + String(participant.participantID) + " Audio.m4a"
        playButton.isEnabled = false
        
        setupRecorder()
        
        fieldAudio.toggleRecording()
        
        fieldAudio.audioRecorder?.delegate = self
        
        stopButton.isEnabled = true
        volumeLevel.isEnabled = false
    }
    
    @IBAction func changeVolume(_ sender: UISlider) {
        fieldAudio.adjustVolume(sender.value)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        setAudioFileLabel()
        
        //using the timer to read the input levels for the sound
        if !timer.isValid{
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(pauseTimerOnEnteringBackground), name:NSNotification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(restartTimerOnLoad), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        guard let _ = self.selectedAudioFileURL else{
            stopButton.isEnabled = false
            playButton.isEnabled = false
            volumeLevel.isEnabled = false
            return
        }
        
        //set the buttons to be deactivated initially
        stopButton.isEnabled = false
        playButton.isEnabled = true
        volumeLevel.isEnabled = true
        
        fieldAudio.audioFileURL = selectedAudioFileURL
    }
    
    func pauseTimerOnEnteringBackground(){
        timer.invalidate()
    }
    
    func restartTimerOnLoad(){
        if !timer.isValid{
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        }
    }
    
    // must be internal or public.
    func update() {
        if let audioPlayer = fieldAudio.audioPlayer{
            if audioPlayer.isPlaying{
                var power: Double = 0.0;
            
                audioPlayer.updateMeters()
            
                for i in 0..<audioPlayer.numberOfChannels{
                    power += Double(audioPlayer.averagePower(forChannel: i))
                    power /= Double(audioPlayer.numberOfChannels)
                }
            
                updateVisualizer(power, playing: true)
            }
        }
        
        if let audioRecorder = fieldAudio.audioRecorder{
            if audioRecorder.isRecording{
                var power: Double = 0.0;
            
                audioRecorder.updateMeters()
                let audioRecorderTemp = audioRecorder

                for i in 0..<2{
                    power += Double(audioRecorderTemp.averagePower(forChannel: i))
                    power /= Double(2)
                }
            updateVisualizer(power, recording: true)
            }
        }   
    }
    
    func updateVisualizer(_ power: Double, playing: Bool = false, recording: Bool = false){
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
            audioVisualizer.color = UIColor(red: 0.75, green: scale, blue: max(2*scale,0.75), alpha: 1.0)
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
        
        fieldAudio.audioFileURL = fieldAudio.directoryURL!.appendingPathComponent(fieldAudio.getAudioFileName(participant))
        
        //the recorder can be setup after the file url and the recording settings have been assigned
        fieldAudio.setupRecorder()
    }
    
    func setAudioFileLabel() {
        let tempRecordings = fieldAudio.listRecordings()!
        
        if(tempRecordings.count > 0){
            if selectedAudioFileLabel.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
                currentlySelectedLabel?.text = "Participant " + String(participant.participantID) + " Audio.m4a"
                playButton.isEnabled = false
            }
            else{
                currentlySelectedLabel?.text = selectedAudioFileLabel
                playButton.isEnabled = true
            }
        }
        else{
            currentlySelectedLabel?.text?.removeAll()
        }
    }
    
    //hides the status bar
    override var prefersStatusBarHidden : Bool {
        return true;
    }
    
    //part of the AVAudioRecorderDelegate protocol, but this is an optional. Using this to inform that we successfully recorded the audio
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        fieldAudio.audioRecorder?.stop()
        
        if flag{
            let alertMessage = UIAlertController(title: "Finished Recording", message: "Successfully recorded audio!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
            resetAudioVisualizer()
        }
    }
    
    //part of the AVAudioPlayerDelegate protocol, but this is an optional as well.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            let alertMessage = UIAlertController(title: "Finish Playing", message:"Finished playing the recording!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            present(alertMessage, animated: true, completion: nil)

            playButton.setImage(UIImage(named: "play"), for: UIControlState())
            resetAudioVisualizer()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showAllRecordings"{
                let navController = segue.destination as! UINavigationController
                let destinationController = navController.viewControllers.first as! RecordListViewController
                let allRecordings = fieldAudio.listRecordings()!
                
                destinationController.files = allRecordings
                if allRecordings.count > 0{
                    destinationController.selectedURL = allRecordings.first!
                }
            
        }
    }
}

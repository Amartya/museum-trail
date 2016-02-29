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

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    var directoryURL: NSURL?
    var audioRecorderURL: NSURL?
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?

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
        if let selectedToPlay = selectedAudioFileURL {
            do{
                try audioPlayer = AVAudioPlayer(contentsOfURL: selectedToPlay)
                
                if !audioPlayer!.playing{
                    playRecordingDelegate()
                }
            }
            catch{
                let alertMessage = UIAlertController(title: "Player Status", message:"No recordings are available, or were selected. Try the recordings list to see if there are any recordings saved.", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
                presentViewController(alertMessage, animated: true, completion: nil)
            }
        }

        if let recorder = audioRecorder {
            if !recorder.recording {
                do{
                    volumeLevel.enabled = true
            
                    listRecordings()
                    
                    if let selectedToPlay = selectedAudioFileURL {
                        try audioPlayer = AVAudioPlayer(contentsOfURL: selectedToPlay)
                        playRecordingDelegate()
                    }
                    else if let recordingToPlay = recordings!.first{
                        try audioPlayer = AVAudioPlayer(contentsOfURL: recordingToPlay)
                        playRecordingDelegate()
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
    
    func playRecordingDelegate(){
        audioPlayer?.delegate = self
        audioPlayer?.volume = volumeLevel.value
        audioPlayer?.meteringEnabled = true
        audioPlayer?.play()
        playButton.selected = true
    }
    
    
    //TODO - Ensure that the pause recording works
    @IBAction func toggleRecording(sender: UIButton) {
        //stop the audio player if it's currently playing
        if let player = audioPlayer{
            if player.playing{
                player.stop()
                playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
                playButton.selected = false
            }
        }
        
        //ensure that the playbutton is disabled and the file name is changed to the participant id for which the recording is being done
        currentlySelectedLabel?.text = "Participant " + String(participant.participantID) + " Audio.m4a"
        playButton.enabled = false
        
        if let recorder = self.audioRecorder{
            if !recorder.recording {
                let audioSession = AVAudioSession.sharedInstance()
                
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
                resetAudioVisualizer()
                recordButton.setImage(UIImage(named: "record"), forState: UIControlState.Normal)
                recordButton.selected = false
            }
        }
        stopButton.enabled = true
        volumeLevel.enabled = false
    }
    
    @IBAction func changeVolume(sender: UISlider) {
        if let _ = audioPlayer{
            audioPlayer?.volume = sender.value
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
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
        
        let tempRecordings = listRecordings()
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
        
        setupRecorder()
        
        //using the timer to read the input levels for the sound
        var _ = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    // must be internal or public.
    func update() {
        if let audioPlayer = audioPlayer{
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
        
        if let audioRecorder = audioRecorder{
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
    
    /**
    returns the list of recordings in the file system in a sorted (by date desc) list
    */
    func listRecordings() -> [NSURL]{
        do {
            //get all audio files
            var urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            urls = urls.filter( { (name: NSURL) -> Bool in return name.lastPathComponent!.hasSuffix("###Audio.m4a")})
            
            //get lastModified date for each of those files
            let urlsAndDates = urls.map { url -> (NSURL, NSDate) in var lastModified : AnyObject?
                                                                            _ = try? url.getResourceValue(&lastModified, forKey: NSURLContentModificationDateKey)
                                                                                return (url, (lastModified)! as! NSDate)}
            let sortedUrlsAndDate = urlsAndDates.sort {$0.1 == $1.1 ? $0.1 > $1.1 : $0.1 > $1.1 }
            
            self.recordings = sortedUrlsAndDate.map{url -> NSURL in return url.0}
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
        
        let calendar = NSCalendar.currentCalendar()
        let today = calendar.components([.Year, .Month, .Day], fromDate: participant.date)
        
        var fileName = String(today.year) + "-" + String(today.month) + "-" + String(today.day) + "###Participant " + String(participant.participantID) + "###Audio.m4a"
        
        let allFilesNames = listRecordings().map({ (name: NSURL) -> String in return name.lastPathComponent!})
        
        //ensuring that if there's a collision in filenames, recordings are not lost
        if allFilesNames.indexOf(fileName) != nil{
            let fileNameComponents = fileName.componentsSeparatedByString("###")
            fileName = fileNameComponents[0] + "###" + fileNameComponents[1] + "(" + NSUUID().UUIDString + ")" + "###Audio.m4a"
        }
        
        audioRecorderURL = directoryURL!.URLByAppendingPathComponent(fileName)
        
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
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    //part of the AVAudioRecorderDelegate protocol, but this is an optional. Using this to inform that we successfully recorded the audio
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            audioRecorder?.stop()
            //after stopping the recording, change the size of the visualizer to hide it behind the music icon
            resetAudioVisualizer()
            
            let alertMessage = UIAlertController(title: "Finished Recording", message: "Successfully recorded audio!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    //part of the AVAudioPlayerDelegate protocol, but this is an optional as well.
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag:Bool) {
            audioPlayer?.stop()
            playButton.selected = false
        
            //after stopping the player, change the size of the visualizer to hide it behind the music icon
            resetAudioVisualizer()
        
            let alertMessage = UIAlertController(title: "Finish Playing", message:"Finished playing the recording!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
            case "showAllRecordings":
                let navController = segue.destinationViewController as! UINavigationController
                let destinationController = navController.viewControllers.first as! RecordListViewController
                let allRecordings = listRecordings()
                
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
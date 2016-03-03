//
//  AudioTrailViewController.swift
//  FieldRecorder
//
//  Created by Amartya on 3/3/16.
//  Copyright © 2016 Amartya. All rights reserved.
//

import Foundation
import AVFoundation

/*
TODO save location data as a separate file
*/
class AudioTrailViewController: UIViewController, EILIndoorLocationManagerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    //add the location manager
    let locationManager = EILIndoorLocationManager()
    
    //location being tracked
    var location: EILLocation!
    
    var participant = Participant()
    
    var fieldAudio = Audio()
    
    var directoryURL: NSURL?
    var recordings: [NSURL]? = []
    
    var selectedAudioFileURL: NSURL?
    var selectedAudioFileLabel: String = ""
    
    @IBOutlet weak var audioVisualizer: AudioVisualizer!
    
    let recordingSettings: [String: AnyObject] =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 16000.0,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    @IBOutlet var stopButton: UIButton!
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet var recordButton: UIButton!
    
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
    }
    
    
    @IBAction func playRecording(sender: UIButton) {
        if let audioPlayer = fieldAudio.audioPlayer {
            if(audioPlayer.playing){
                fieldAudio.pausePlayer()
                playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
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
        playButton.enabled = false
        
        setupRecorder()
        
        fieldAudio.toggleRecording()
        
        fieldAudio.audioRecorder?.delegate = self
        
        stopButton.enabled = true
    }

    
    @IBOutlet var indoorLocationOutput: UILabel!
    
    //view used to visualize position from Cartesian Estimote coords to iOS coods
    @IBOutlet weak var locationView: EILIndoorLocationView!
    
    @IBOutlet weak var traceSwitch: UISwitch!
    
    //toggle trace display
    @IBAction func showTrace(sender: UISwitch) {
        if let _ = self.locationView{
            self.locationView.showTrace = sender.on
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traceSwitch.enabled = true
        
        setupIndoorLocation()
        indoorLocationOutput.text = "fetching location data..."
        
        //set the buttons to be deactivated initially
        stopButton.enabled = false
        playButton.enabled = false
        
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
    }
    
    func setupRecorder(){
        //set the recorder's settings
        fieldAudio.recordingSettings = recordingSettings
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        fieldAudio.audioFileURL = fieldAudio.directoryURL!.URLByAppendingPathComponent(fieldAudio.getAudioFileName(self.participant))
        
        //the recorder can be setup after the file url and the recording settings have been assigned
        fieldAudio.setupRecorder()
    }
    
    func setupIndoorLocation(){
        //the app id and token are generated in the Estimote cloud
        ESTConfig.setupAppID("museum-trail-oo1", andAppToken: "f6b8110fd473519734dfd2c48cf485e9")
        
        //set the location manager's delegate
        self.locationManager.delegate = self
        
        /**
         Uncomment this block to get a list of all saved locations
         let fetchLocations = EILRequestFetchLocations()
         fetchLocations.sendRequestWithCompletion{(locations, error) in
         if let locations = locations{
         print(locations)
         }
         }*/
         
         //try to fetch location from Estimote Cloud, otherwise, build location
         //N.B. the locationIdentifier is different from the name we give to the location using setLocationName
        let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "annenberg-hall-commons-koi")
        fetchLocationRequest.sendRequestWithCompletion { (location, error) in
            if let location = location {
                self.location = location
                self.completeLocationViewerSetup()
            }
            else {
                let locationBuilder = EILLocationBuilder.init()
                locationBuilder.setLocationBoundaryPoints([EILPoint(x: 0, y: 0), EILPoint(x: 0, y: 6.2), EILPoint(x: 9.78, y: 6.2), EILPoint(x: 9.78, y: 0)])
                
                /**
                Current list of the 6 beacons we have
                1 - F0:34:B5:DC:9C:CE
                2 - CA:9F:BB:01:B1:0A
                3 - EA:1F:87:62:C6:B8
                4 - D7:10:BB:1D:D9:18
                5 - C0:DC:98:37:75:9D
                6 - C3:15:A9:E0:2B:F3
                */
                locationBuilder.addBeaconWithIdentifier("F0:34:B5:DC:9C:CE", atBoundarySegmentIndex: 0, inDistance: 3.1, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("CA:9F:BB:01:B1:0A", atBoundarySegmentIndex: 1, inDistance: 4.89, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("EA:1F:87:62:C6:B8", atBoundarySegmentIndex: 2, inDistance: 3.1, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("D7:10:BB:1D:D9:18", atBoundarySegmentIndex: 3, inDistance: 4.89, fromSide: EILLocationBuilderSide.RightSide)
                
                /**currently commented out, to be changed at the Field
                locationBuilder.addBeaconWithIdentifier("C0:DC:98:37:75:9D", atBoundarySegmentIndex: 3, inDistance: 4.89, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("C3:15:A9:E0:2B:F3", atBoundarySegmentIndex: 3, inDistance: 4.89, fromSide: EILLocationBuilderSide.RightSide)
                */
                
                locationBuilder.setLocationOrientation(63.0)
                locationBuilder.setLocationName("Annenberg Hall Commons")
                
                self.location = locationBuilder.build()
                
                //after building the location, save it to Estimote Cloud
                let requestAddLocation = EILRequestAddLocation.init(location: self.location)
                requestAddLocation.sendRequestWithCompletion({(EILRequestAddLocationBlock) in print("saved location")})
                
                self.completeLocationViewerSetup()
            }
        }
    }
    
    func completeLocationViewerSetup(){
        //configure the location view
        self.locationView.showTrace = traceSwitch.on
        self.locationView.rotateOnPositionUpdate = false
        self.locationView.drawLocation(self.location)
        
        //setup up handler for position updates
        self.locationManager.startPositionUpdatesForLocation(self.location)
    }
    
    func indoorLocationManager(manager: EILIndoorLocationManager,
        didFailToUpdatePositionWithError error: NSError) {
            print("failed to update position: \(error)")
    }
    
    func indoorLocationManager(manager: EILIndoorLocationManager,
        didUpdatePosition position: EILOrientedPoint,
        withAccuracy positionAccuracy: EILPositionAccuracy,
        inLocation location: EILLocation) {
            var accuracy: String!
            switch positionAccuracy {
            case .VeryHigh: accuracy = "+/- 1.00m"
            case .High:     accuracy = "+/- 1.62m"
            case .Medium:   accuracy = "+/- 2.62m"
            case .Low:      accuracy = "+/- 4.24m"
            case .VeryLow:  accuracy = "+/- ? :-("
            default: print("positioning not working")
            }
            
            indoorLocationOutput.text = String(format: "x: %5.2f, y: %5.2f, accuracy: %@",
                position.x, position.y, accuracy)
            
            //update position in the location view setup earlier
            self.locationView.updatePosition(position)
    }
    
    //part of the AVAudioRecorderDelegate protocol, but this is an optional. Using this to inform that we successfully recorded the audio
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        fieldAudio.audioRecorder?.stop()
        
        if flag{
            let alertMessage = UIAlertController(title: "Finished Recording", message: "Successfully recorded audio!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertMessage, animated: true, completion: nil)
        }
    }
    
    //part of the AVAudioPlayerDelegate protocol, but this is an optional as well.
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            let alertMessage = UIAlertController(title: "Finish Playing", message:"Finished playing the recording!", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
            presentViewController(alertMessage, animated: true, completion: nil)
            
            playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showParticipantFromAudioTrail"{
            let destinationController = segue.destinationViewController as! ParticipantViewController
            destinationController.participant = self.participant
        }
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
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
    
    var fieldAudio = Audio()
    
    var directoryURL: NSURL?
    var recordings: [NSURL]? = []
    
    var selectedAudioFileURL: NSURL?
    var selectedAudioFileLabel: String = ""
    
    var estimoteLocation = EstimoteLocation()
    
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
        
        estimoteLocation.directoryURL = fieldAudio.directoryURL
        
        estimoteLocation.trailFileURL = estimoteLocation.directoryURL!.URLByAppendingPathComponent(estimoteLocation.getTrailFileName(participant))
    }
    
    func setupRecorder(){
        //set the recorder's settings
        fieldAudio.recordingSettings = recordingSettings
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        fieldAudio.audioFileURL = fieldAudio.directoryURL!.URLByAppendingPathComponent(fieldAudio.getAudioFileName(participant))
        
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
        let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "china-hall")
        fetchLocationRequest.sendRequestWithCompletion { (location, error) in
            if let location = location {
                self.location = location
                self.completeLocationViewerSetup()
            }
            else {
                let locationBuilder = EILLocationBuilder.init()
                //locationBuilder.setLocationBoundaryPoints([EILPoint(x: 0, y: 0), EILPoint(x: 0, y: 6.2), EILPoint(x: 9.78, y: 6.2), EILPoint(x: 9.78, y: 0)])
                
                locationBuilder.setLocationBoundaryPoints([EILPoint(x: 0, y: 0), EILPoint(x: 0, y: 9.55), EILPoint(x: 9.6, y: 9.55), EILPoint(x: 19.2, y: 9.55),
                    EILPoint(x: 27.4, y: 9.55), EILPoint(x: 34, y: 9.55), EILPoint(x: 42, y: 9.55), EILPoint(x: 51.7, y: 9.55),
                    EILPoint(x: 51.7, y: 0), EILPoint(x: 37.6, y: 0.0), EILPoint(x: 31.3, y: 5.0), EILPoint(x: 21.2, y: 0.0),EILPoint(x: 10.6, y: 0.0)])
                /**
                 Current list of the 12 beacons we have
                 1-E8:C2:89:54:B0:7B
                 2-FD:7d:75:01:A1:C6
                 3-C9:23:FC:8B:79:74
                 4-FB:E0:DE:9B:44:77
                 5-E9:79:81:DD:A0:3C
                 6-EA:1f:87:62:C6:B8
                 7-CA:4a:85:8E:EC:FC
                 8-D6:00:80:94:12:92
                 9-C0:CC:3D:C9:A3:8E
                 10-FC:89:D7:64:DC:A6
                 11-E8:55:F8:AC:45:AA
                 12-D6:55:C3:8E:93:C8
                 13-E5:45:02:F4:39:A0
                 14-CA:9F:BB:01:B1:0A
                 15-F3:99:71:AC:B4:20
                 */
                locationBuilder.addBeaconWithIdentifier("E8:C2:89:54:B0:7B", atBoundarySegmentIndex: 0, inDistance: 4.95, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("FD:7d:75:01:A1:C6", atBoundarySegmentIndex: 1, inDistance: 4.9, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("C9:23:FC:8B:79:74", atBoundarySegmentIndex: 2, inDistance: 4.8, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("FB:E0:DE:9B:44:77", atBoundarySegmentIndex: 3, inDistance: 2.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("E9:79:81:DD:A0:3C", atBoundarySegmentIndex: 4, inDistance: 3.9, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("EA:1f:87:62:C6:B8", atBoundarySegmentIndex: 5, inDistance: 3.6, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("CA:4a:85:8E:EC:FC", atBoundarySegmentIndex: 6, inDistance: 5.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("D6:00:80:94:12:92", atBoundarySegmentIndex: 7, inDistance: 3.08, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("C0:CC:3D:C9:A3:8E", atBoundarySegmentIndex: 8, inDistance: 7.7, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("FC:89:D7:64:DC:A6", atBoundarySegmentIndex: 9, inDistance: 2.6, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("E8:55:F8:AC:45:AA", atBoundarySegmentIndex: 10, inDistance: 2.3, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("D6:55:C3:8E:93:C8", atBoundarySegmentIndex: 11, inDistance: 6.75, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("E5:45:02:F4:39:A0", atBoundarySegmentIndex: 12, inDistance: 5.6, fromSide: EILLocationBuilderSide.LeftSide)
                
                locationBuilder.setLocationOrientation(0.0)
                locationBuilder.setLocationName("China Hall")
                
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
            
            let currPosition = String(format: "x: %5.2f, y: %5.2f, accuracy: %@, timeStamp: %@",
                position.x, position.y, accuracy, Utility.getCurrentDeviceTimestamp())
            indoorLocationOutput.text = currPosition
            
            do{
                try currPosition.appendLineToURL(estimoteLocation.trailFileURL!)
            }
            catch{
                print("error appending location data to file")
            }

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
        //
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
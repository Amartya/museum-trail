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
    
    var directoryURL: URL?
    var recordings: [URL]? = []
    
    var selectedAudioFileURL: URL?
    var selectedAudioFileLabel: String = ""
    
    var estimoteLocation = EstimoteLocation()
    
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
    }
    
    
    @IBAction func playRecording(_ sender: UIButton) {
        if let audioPlayer = fieldAudio.audioPlayer {
            if(audioPlayer.isPlaying){
                fieldAudio.pausePlayer()
                playButton.setImage(UIImage(named: "play"), for: UIControlState())
            }
            else if let currentTime = fieldAudio.audioCurrentTime{
                fieldAudio.audioPlayer?.play(atTime: currentTime)
                playButton.setImage(UIImage(named: "pause"), for: UIControlState())
            }
        }
        else{
            fieldAudio.audioPlayer?.delegate = self
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
        playButton.isEnabled = false
        
        setupRecorder()
        
        fieldAudio.toggleRecording()
        
        fieldAudio.audioRecorder?.delegate = self
        
        stopButton.isEnabled = true
    }

    
    @IBOutlet var indoorLocationOutput: UILabel!
    
    //view used to visualize position from Cartesian Estimote coords to iOS coods
    @IBOutlet weak var locationView: EILIndoorLocationView!
    
    @IBOutlet weak var traceSwitch: UISwitch!
    
    //toggle trace display
    @IBAction func showTrace(_ sender: UISwitch) {
        if let _ = self.locationView{
            self.locationView.showTrace = sender.isOn
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traceSwitch.isEnabled = true
        
        setupIndoorLocation()
        indoorLocationOutput.text = "fetching location data..."
        
        //set the buttons to be deactivated initially
        stopButton.isEnabled = false
        playButton.isEnabled = false
        
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        estimoteLocation.directoryURL = fieldAudio.directoryURL
        
        estimoteLocation.trailFileURL = estimoteLocation.directoryURL!.appendingPathComponent(estimoteLocation.getTrailFileName(participant))
    }
    
    func setupRecorder(){
        //set the recorder's settings
        fieldAudio.recordingSettings = recordingSettings
        fieldAudio.directoryURL = Utility.getAppDirectoryURL()
        
        fieldAudio.audioFileURL = fieldAudio.directoryURL!.appendingPathComponent(fieldAudio.getAudioFileName(participant))
        
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
        fetchLocationRequest.sendRequest { (location, error) in
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
                locationBuilder.addBeacon(withIdentifier: "F0:34:B5:DC:9C:CE", atBoundarySegmentIndex: 0, inDistance: 3.1, from: EILLocationBuilderSide.leftSide)
                locationBuilder.addBeacon(withIdentifier: "CA:9F:BB:01:B1:0A", atBoundarySegmentIndex: 1, inDistance: 4.89, from: EILLocationBuilderSide.leftSide)
                locationBuilder.addBeacon(withIdentifier: "EA:1F:87:62:C6:B8", atBoundarySegmentIndex: 2, inDistance: 3.1, from: EILLocationBuilderSide.rightSide)
                locationBuilder.addBeacon(withIdentifier: "D7:10:BB:1D:D9:18", atBoundarySegmentIndex: 3, inDistance: 4.89, from: EILLocationBuilderSide.rightSide)
                
                /**currently commented out, to be changed at the Field
                locationBuilder.addBeaconWithIdentifier("C0:DC:98:37:75:9D", atBoundarySegmentIndex: 3, inDistance: 4.89, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("C3:15:A9:E0:2B:F3", atBoundarySegmentIndex: 3, inDistance: 4.89, fromSide: EILLocationBuilderSide.RightSide)
                */
                
                locationBuilder.setLocationOrientation(63.0)
                locationBuilder.setLocationName("Annenberg Hall Commons")
                
                self.location = locationBuilder.build()
                
                //after building the location, save it to Estimote Cloud
                let requestAddLocation = EILRequestAddLocation.init(location: self.location)
                requestAddLocation.sendRequest(completion: {(EILRequestAddLocationBlock) in print("saved location")})
                
                self.completeLocationViewerSetup()
            }
        }
    }
    
    func completeLocationViewerSetup(){
        //configure the location view
        self.locationView.showTrace = traceSwitch.isOn
        self.locationView.rotateOnPositionUpdate = false
        self.locationView.drawLocation(self.location)
        
        //setup up handler for position updates
        self.locationManager.startPositionUpdates(for: self.location)
    }
    
    func indoorLocationManager(_ manager: EILIndoorLocationManager,
        didFailToUpdatePositionWithError error: NSError) {
            print("failed to update position: \(error)")
    }
    
    func indoorLocationManager(_ manager: EILIndoorLocationManager,
        didUpdatePosition position: EILOrientedPoint,
        with positionAccuracy: EILPositionAccuracy,
        in location: EILLocation) {
            var accuracy: String!
            switch positionAccuracy {
            case .veryHigh: accuracy = "+/- 1.00m"
            case .high:     accuracy = "+/- 1.62m"
            case .medium:   accuracy = "+/- 2.62m"
            case .low:      accuracy = "+/- 4.24m"
            case .veryLow:  accuracy = "+/- ? :-("
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
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        fieldAudio.audioRecorder?.stop()
        
        if flag{
            let alertMessage = UIAlertController(title: "Finished Recording", message: "Successfully recorded audio!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
        }
    }
    
    //part of the AVAudioPlayerDelegate protocol, but this is an optional as well.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            let alertMessage = UIAlertController(title: "Finish Playing", message:"Finished playing the recording!", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            present(alertMessage, animated: true, completion: nil)
            
            playButton.setImage(UIImage(named: "play"), for: UIControlState())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
    }
    
    //hides the status bar
    override var prefersStatusBarHidden : Bool {
        return true;
    }
}

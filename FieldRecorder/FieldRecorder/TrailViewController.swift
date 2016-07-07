//
//  TrailViewController.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/23/16.
//  Copyright © 2016 Amartya. All rights reserved.
//
import Foundation
import UIKit

//add the EILIndoorLocationManagerDelegate protocol to hook into the Estimote SDK
class TrailViewController: UIViewController, EILIndoorLocationManagerDelegate, ESTTriggerManagerDelegate, ESTBeaconManagerDelegate  {
    let beaconManager = ESTBeaconManager()
    
    //add the location manager
    let locationManager = EILIndoorLocationManager()
    
    //add the trigger manager for the nearables
    let triggerManager = ESTTriggerManager()
    
    //location being tracked
    var location: EILLocation!
    
    var estimoteLocation = EstimoteLocation()
    
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
        
        setupStickers()
        
        estimoteLocation.directoryURL = Utility.getAppDirectoryURL()
        
        estimoteLocation.trailFileURL = estimoteLocation.directoryURL!.URLByAppendingPathComponent(estimoteLocation.getTrailFileName(participant))
    }
    
    func setupIndoorLocation(){
        //the app id and token are generated in the Estimote cloud
        ESTConfig.setupAppID("museum-trail-oo1", andAppToken: "f6b8110fd473519734dfd2c48cf485e9")
        
        //set the location manager's delegate
        self.locationManager.delegate = self
        
        self.beaconManager.delegate = self
        
        self.beaconManager.requestAlwaysAuthorization()
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
    
    func setupStickers(){
        self.triggerManager.delegate = self
        
        // add this below:
        let rule1 = ESTOrientationRule.orientationEquals(
            .Horizontal, forNearableIdentifier: "9468e46cd9e542d8")
        let rule2 = ESTMotionRule.motionStateEquals(
            true, forNearableType: .Door)
        let trigger = ESTTrigger(rules: [rule1, rule2], identifier: "door")
        
        self.triggerManager.startMonitoringForTrigger(trigger)
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
    
    func triggerManager(manager: ESTTriggerManager,
                        triggerChangedState trigger: ESTTrigger) {
        if (trigger.identifier == "door" && trigger.state == true) {
            print("Close to the door")
        } else {
            print("Outside the door")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showAllTrails"{
            let navController = segue.destinationViewController as! UINavigationController
            let destinationController = navController.viewControllers.first as! TrailListViewController
            
            destinationController.files = estimoteLocation.listTrails()!
            
            if destinationController.files.count > 0{
                destinationController.selectedURL = destinationController.files.first!
            }
        }
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}

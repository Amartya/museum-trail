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
class TrailViewController: UIViewController, EILIndoorLocationManagerDelegate  {
    //add the location manager
    let locationManager = EILIndoorLocationManager()
    
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
        
        estimoteLocation.directoryURL = Utility.getAppDirectoryURL()
        
        estimoteLocation.trailFileURL = estimoteLocation.directoryURL!.URLByAppendingPathComponent(estimoteLocation.getTrailFileName(participant))
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
                locationBuilder.setLocationBoundaryPoints([EILPoint(x: 0, y: 0), EILPoint(x: 0, y: 6.2), EILPoint(x: 9.78, y: 6.2), EILPoint(x: 9.78, y: 0)])
        
                locationBuilder.setLocationBoundaryPoints([EILPoint(x: 0, y: 0), EILPoint(x: 0, y: 8.0), EILPoint(x: 8.0, y: 8.0), EILPoint(x: 14.0, y: 8.0),
                                                           EILPoint(x: 19.0, y: 8.0), EILPoint(x: 23.0, y: 8.0), EILPoint(x: 27.0, y: 8.0), EILPoint(x: 34.0, y: 8.0),
                                                           EILPoint(x: 34.0, y: 0), EILPoint(x: 25.0, y: 0.0), EILPoint(x: 15.0, y: 0.0), EILPoint(x: 8.0, y: 0.0)])
                /**
                Current list of the 12 beacons we have
                1 - F0:34:B5:DC:9C:CE
                2 - CA:9F:BB:01:B1:0A
                3 - EA:1F:87:62:C6:B8
                4 - D7:10:BB:1D:D9:18
                5 - C0:DC:98:37:75:9D
                6 - C3:15:A9:E0:2B:F3
                7 - C3:0D:EB:D1:9B:87
                8 - D6:55:C3:8E:93:C8
                9 - E8:55:F8:AC:45:AA
                10 - E5:45:02:F4:39:A0
                11 - C1:8D:60:7F:D4:5E
                12 - F3:99:71:AC:B4:20
                */
                locationBuilder.addBeaconWithIdentifier("F0:34:B5:DC:9C:CE", atBoundarySegmentIndex: 0, inDistance: 4.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("CA:9F:BB:01:B1:0A", atBoundarySegmentIndex: 1, inDistance: 4.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("EA:1F:87:62:C6:B8", atBoundarySegmentIndex: 2, inDistance: 3.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("D7:10:BB:1D:D9:18", atBoundarySegmentIndex: 3, inDistance: 2.5, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("C0:DC:98:37:75:9D", atBoundarySegmentIndex: 4, inDistance: 2.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("C3:15:A9:E0:2B:F3", atBoundarySegmentIndex: 5, inDistance: 2.0, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("C3:0D:EB:D1:9B:87", atBoundarySegmentIndex: 6, inDistance: 3.5, fromSide: EILLocationBuilderSide.LeftSide)
                locationBuilder.addBeaconWithIdentifier("D6:55:C3:8E:93:C8", atBoundarySegmentIndex: 7, inDistance: 3.0, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("E8:55:F8:AC:45:AA", atBoundarySegmentIndex: 8, inDistance: 4.5, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("E5:45:02:F4:39:A0", atBoundarySegmentIndex: 9, inDistance: 5.0, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("C1:8D:60:7F:D4:5E", atBoundarySegmentIndex: 10, inDistance: 5.0, fromSide: EILLocationBuilderSide.RightSide)
                locationBuilder.addBeaconWithIdentifier("F3:99:71:AC:B4:20", atBoundarySegmentIndex: 11, inDistance: 4.0, fromSide: EILLocationBuilderSide.RightSide)
                
                locationBuilder.setLocationOrientation(3.0)
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

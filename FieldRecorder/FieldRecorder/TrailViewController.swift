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
    
    var participant = Participant()
    
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
        
        estimoteLocation.trailFileURL = estimoteLocation.directoryURL!.URLByAppendingPathComponent(estimoteLocation.getTrailFileName(self.participant))
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
            
            let currPosition = String(format: "x: %5.2f, y: %5.2f, accuracy: %@",
                position.x, position.y, accuracy)
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
        if segue.identifier == "showParticipantFromTrail"{
            let destinationController = segue.destinationViewController as! ParticipantViewController
            destinationController.participant = self.participant
        }
        else if segue.identifier! == "showAllTrails"{
            let navController = segue.destinationViewController as! UINavigationController
            let destinationController = navController.viewControllers.first as! TrailListViewController
            
            destinationController.files = estimoteLocation.listTrails()!
            
            if destinationController.files.count > 0{
                destinationController.selectedURL = destinationController.files.first!
            }
            
            //store the participant id across screens
            destinationController.participant = self.participant
        }
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}

//
//  TrailViewController.swift
//  FieldRecorder
//
//  Created by Amartya Banerjee on 2/23/16.
//  Copyright © 2016 Amartya. All rights reserved.
//
import Foundation
import UIKit

// 1. Add the EILIndoorLocationManagerDelegate protocol
class TrailViewController: UIViewController, EILIndoorLocationManagerDelegate  {
    
    // 2. Add the location manager
    let locationManager = EILIndoorLocationManager()
    
    var location: EILLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 3. Set the location manager's delegate
        self.locationManager.delegate = self
        
        ESTConfig.setupAppID("museum-trail-oo1", andAppToken: "f6b8110fd473519734dfd2c48cf485e9")
        
        var location = EILLocationBuilder.init()
        location.setLocationBoundaryPoints([EILPoint(x: 0, y: 0),EILPoint(x: 0, y: 5),EILPoint(x: 5, y: 5),
            EILPoint(x: 5, y: 0)])
        
        location.setLocationOrientation(0)
        
        let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "my-kitchen")
        fetchLocationRequest.sendRequestWithCompletion { (location, error) in
            if location != nil {
                self.location = location!
                
                self.locationManager.startPositionUpdatesForLocation(self.location)
            } else {
                print("can't fetch location: \(error)")
            }
        }
    }
    
    func indoorLocationManager(manager: EILIndoorLocationManager!,
        didFailToUpdatePositionWithError error: NSError!) {
            print("failed to update position: \(error)")
    }
    
    func indoorLocationManager(manager: EILIndoorLocationManager!,
        didUpdatePosition position: EILOrientedPoint!,
        withAccuracy positionAccuracy: EILPositionAccuracy,
        inLocation location: EILLocation!) {
            var accuracy: String!
            switch positionAccuracy {
            case .VeryHigh: accuracy = "+/- 1.00m"
            case .High:     accuracy = "+/- 1.62m"
            case .Medium:   accuracy = "+/- 2.62m"
            case .Low:      accuracy = "+/- 4.24m"
            case .VeryLow:  accuracy = "+/- ? :-("
            default: print("positioning not working")
            }
            
            print(String(format: "x: %5.2f, y: %5.2f, orientation: %3.0f, accuracy: %@",
                position.x, position.y, position.orientation, accuracy))
    }
    
    //hides the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}
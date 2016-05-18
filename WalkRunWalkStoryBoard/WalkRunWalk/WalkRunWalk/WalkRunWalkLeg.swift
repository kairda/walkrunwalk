//
//  WalkRunWalkLeg.swift
//  WalkRunWalk
//
//  Created by Kai Renz on 16.05.16.
//  Copyright © 2016 KaiRenz. All rights reserved.
//

import Foundation
import CoreLocation

// this class holds the information about the leg of the walk/run/walk cycle.

public class WalkRunWalkLeg {
    
    var entryType : String  = "";
    var timeSeconds : Int = 0;
    private var distMeter : Double = -1;
    var locations : [CLLocation]?;
    
    public init(firstLocation : CLLocation? ) {
        
        if (firstLocation != nil) {
            addLocation(firstLocation!);
        }
    }
    
    // helpers for geolocation stuff ...
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    private func calculateDistance(point1 : CLLocation?, point2 : CLLocation?) -> Double {
        
        if (point1 == nil || point2 == nil) {
            return 0;
        }
        
        let lat1 = degreesToRadians(point1!.coordinate.latitude)
        let lon1 = degreesToRadians(point1!.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2!.coordinate.latitude);
        let lon2 = degreesToRadians(point2!.coordinate.longitude);
        
        let deltaP = (lat2 - lat1)
        let deltaL = (lon2 - lon1)
        let a = sin(deltaP/2) * sin(deltaP/2) + cos(lat1) * cos(lat2) * sin(deltaL/2) * sin(deltaL/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let radius : Double = 6371000;
        let d = radius * c
        
        return d;
    }
    
    func getDistance() -> Double {
        if (distMeter >= 0) {
            return distMeter;
        }
        
        if (locations == nil || locations!.count == 1 ) {
            distMeter = 0;
            return distMeter;
        }
        
        var individualDistance : Double = 0;
        
        var previousLocation : CLLocation? = nil;
        
        for location in locations! {
            if (previousLocation != nil) {
                let smalldist = calculateDistance(previousLocation!, point2: location);
                if (smalldist > 0) {
                    individualDistance += smalldist;
                }
            }
            previousLocation = location;
            
        }
        
        distMeter = calculateDistance(locations![0], point2: locations![locations!.count-1])
        
        // print("DistMeter is " + String(distMeter) + " individualDistance is " + String(individualDistance));
        if (individualDistance > distMeter) {
            distMeter = individualDistance;
        }
        return distMeter;
    }
    
    func addLocation(location : CLLocation! ) {
        if (locations == nil) {
            locations = [CLLocation]();
        }
        locations!.append(location);
    }

}
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
    
    var listOfLocationLists : [[CLLocation]!]?;
    // var locations : [CLLocation]?;
    
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
        
        if (listOfLocationLists == nil || listOfLocationLists!.count == 0) {
            return 0;
        }
        
        
        
        var distance : Double = 0;
        
        for locations in listOfLocationLists! {
            distance += getDistanceForLocationsArray(locations);
        }
        
        
        distMeter = distance;
        return distMeter;
        
    }
    
    private func getDistanceForLocationsArray(locations : [CLLocation]) -> Double {
        
        var distance : Double = 0;
        
        if (locations.count < 2 ) {
            return distance;
        }
        
        var individualDistance : Double = 0;
        
        var previousLocation : CLLocation? = nil;
        
        for location in locations {
            if (previousLocation != nil) {
                let smalldist = calculateDistance(previousLocation!, point2: location);
                if (smalldist > 0) {
                    individualDistance += smalldist;
                }
            }
            previousLocation = location;
            
        }
        
        distance = calculateDistance(locations[0], point2: locations[locations.count-1])
        
        // print("DistMeter is " + String(distMeter) + " individualDistance is " + String(individualDistance));
        if (individualDistance > distance) {
            distance = individualDistance;
        }
        return distance;
    }
    
    func addLocation(location : CLLocation! ) {
        
        if (listOfLocationLists == nil) {
            listOfLocationLists = [[CLLocation]!]();
            
        }
        
        var currentLocations : [CLLocation]!;
        if (listOfLocationLists!.count > 0) {
            currentLocations = listOfLocationLists![listOfLocationLists!.count-1];
        } else {
            currentLocations = [CLLocation]();
            
        }

        if (currentLocations.count > 0) {
            // we need to check, if the distance is too far, in this case we will create a new "subleg"
            
            let prevLocation : CLLocation = currentLocations[currentLocations!.count-1];
            let dist = calculateDistance(prevLocation, point2: location);
            if (dist > 12) {
                // then we create a new leg ....
                currentLocations = [CLLocation]();
                currentLocations!.append(location);
                listOfLocationLists!.append(currentLocations!);
                return;
                
            } else {
                currentLocations!.append(location);
            }
            
            
        } else {
            currentLocations!.append(location);
        }
        
        if (listOfLocationLists?.count > 0) {
            listOfLocationLists?.removeLast();
        }
        listOfLocationLists?.append(currentLocations!);

    }

}
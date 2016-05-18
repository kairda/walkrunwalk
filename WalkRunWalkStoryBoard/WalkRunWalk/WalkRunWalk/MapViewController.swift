//
//  MapViewController.swift
//  WalkRunWalk
//
//  Created by Kai Renz on 16.05.16.
//  Copyright © 2016 KaiRenz. All rights reserved.
//

import Foundation
import MapKit

public class MapViewController : UIViewController, MKMapViewDelegate {

    
    var legs : [WalkRunWalkLeg]?;
    var timeSecondsSumString : String? = "";
    var sumWalkString : String? = "";
    var sumRunString : String? = "";
    
    
    @IBOutlet var mapKitView : MKMapView?
    
    @IBOutlet var timeSecondsSumLabel : UILabel?;
    @IBOutlet var sumWalkLabel : UILabel?;
    @IBOutlet var sumRunLabel: UILabel?;

    
    
//    override public func targetViewControllerForAction(action: Selector, sender: AnyObject?) -> UIViewController? {
//        return self as UIViewController;
//    }
    
    
    public override func viewDidLoad() {
        
        mapKitView!.delegate = self;
        mapKitView!.mapType = MKMapType.Hybrid;
        
        timeSecondsSumLabel!.text = timeSecondsSumString;
        sumWalkLabel!.text = sumWalkString;
        sumRunLabel!.text = sumRunString;

        if (legs != nil && legs!.count > 0) {
            
            var isFirst : Bool = true;
            
            for (var index : Int = legs!.count-1; index >= 0; index -= 1 ) {
                let leg : WalkRunWalkLeg! = legs![index];
        
                let locations : [CLLocation]? = leg.locations;
                if (locations != nil && locations!.count > 0) {
                    
                    var coordinates : [CLLocationCoordinate2D] = [];
                    
                    for location in locations! {
                        coordinates.append(location.coordinate);
                    }
                    
                    let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
                    polyline.title = leg.entryType;
                    mapKitView?.addOverlay(polyline)
                   
                    
                    if (isFirst) {
                        
                        let mkAnnotation : MKPointAnnotation = MKPointAnnotation();
                        
                        mkAnnotation.coordinate = coordinates[0];
                        mkAnnotation.title = "Start";
                        mapKitView?.addAnnotation(mkAnnotation)
                        
                        mapKitView?.centerCoordinate = mkAnnotation.coordinate;
                        var region = mapKitView?.region;
                        
                        region!.center = coordinates[0];
                        
                        region!.span.longitudeDelta = 0.00544927536
                        region!.span.latitudeDelta = 0.00544927536
                        mapKitView?.region = region!;

                        isFirst = false;
                    }
                 
                    if (index == 0) {
                        // then this is the last leg ...
                        let mkAnnotation : MKPointAnnotation = MKPointAnnotation();
                        
                        mkAnnotation.coordinate = coordinates[coordinates.count-1];
                        mkAnnotation.title = "End";
                        mapKitView?.addAnnotation(mkAnnotation)
                        
                    }
                }
                
            }
        }

    }
    
    public func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            if (overlay.title! == "Run") {
                polylineRenderer.strokeColor = UIColor.orangeColor();
            } else {
                polylineRenderer.strokeColor = UIColor.greenColor();
                
            }
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
        
    }

    public func setLegs(legs : [WalkRunWalkLeg], timeSecondsSumString : String, sumWalkString : String, sumRunString : String) {
        
        self.legs = legs;
        self.timeSecondsSumString = timeSecondsSumString;
        self.sumWalkString = sumWalkString;
        self.sumRunString = sumRunString;

    }
    
    @IBAction func dismissView() {
        self.dismissViewControllerAnimated(true, completion: nil )
    }

}

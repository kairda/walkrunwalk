//
//  ViewController.swift
//  WalkRunWalk
//
//  Created by Kai Renz on 14.05.16.
//  Copyright © 2016 KaiRenz. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                      CLLocationManagerDelegate {
    
    var walkCycleLengthSeconds : Int = 0;
    var runCycleLengthSeconds : Int = 0;
    
    var remainingSeconds : Int = 0;
    var countUpSeconds : Int = 0;
    var secondsSum : Int = 0;
    
    var sumWalkedSeconds : Int = 0;
    var sumWalkedMeters : Double = 0;
    var sumRunSeconds : Int = 0;
    var sumRunMeters : Double = 0;
    
    var timer : NSTimer?;
    var running : Bool = false;
    var pausing : Bool = false;
    var isAutomatic : Bool = false;
    
    var legs : [WalkRunWalkLeg] = [WalkRunWalkLeg]();
    var currentLeg : WalkRunWalkLeg?;
    
    @IBOutlet var walkCycleLengthLabel : UILabel?
    @IBOutlet var runCycleLengthLabel : UILabel?
    
    @IBOutlet var walkCycleLengthStepper : UIStepper?
    @IBOutlet var runCycleLengthStepper : UIStepper?

    @IBOutlet var activityLabel : UILabel?
    
    @IBOutlet var timeCountDownLabel : UILabel?;
    @IBOutlet var timeCountUpLabel : UILabel?;
    @IBOutlet var timeSecondsSumLabel : UILabel?;
    
    
    @IBOutlet var sumWalkLabel : UILabel?;
    @IBOutlet var sumRunLabel: UILabel?;
    
    @IBOutlet var automaticSwitch : UISwitch?;
    
    @IBOutlet var walkRunButton : UIButton?;
    @IBOutlet var pauseButton : UIButton?;
    @IBOutlet var stopButton : UIButton?;
    @IBOutlet var mapButton : UIButton?;
    
    @IBOutlet var tableView : UITableView!;
    
    var locationManager: CLLocationManager!
    var locationAtLastToggle : CLLocation?
    var currentLocation : CLLocation?
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder);
        
        setDefaults();
    }
    
    func setDefaults() {
        
        running = false;
        pausing = false;
        
        if (timer != nil) {
            timer?.invalidate();
            timer = nil;
        }
        
        walkCycleLengthSeconds = 30;
        if (walkCycleLengthStepper != nil) {
            walkCycleLengthSeconds = Int(walkCycleLengthStepper!.value);
        }
        runCycleLengthSeconds = 60;
        if (runCycleLengthStepper != nil) {
            runCycleLengthSeconds = Int(runCycleLengthStepper!.value);
        }
        remainingSeconds = walkCycleLengthSeconds;
        countUpSeconds = 0;
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        
        setDefaults();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom cell
        let nib = UINib(nibName: "WalkRunWalkTableCellPlayaround", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "walkrunwalktablecell")
        
        UIApplication.sharedApplication().idleTimerDisabled = true

        print(self.view.center)
        
        self.running = false;
        timer = nil;
        
        self.view.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.9);
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        

        refreshDisplay();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func showViewController(vc: UIViewController, sender: AnyObject?) {
        
        let viewcontroller : MapViewController = vc as! MapViewController
 
        viewcontroller.setLegs(self.legs, timeSecondsSumString: ViewController.getTimeString(secondsSum),
                               sumWalkString: sumWalkLabel!.text!, sumRunString : sumRunLabel!.text!);
        
        self.presentViewController(viewcontroller, animated: true, completion: nil )
    }
    
    
    @IBAction func walkRunButtonClick(sender:UIButton!) {
        toggleWalkRun();
        refreshDisplay();
    }
    
    @IBAction func pauseClick(sender: UIButton!) {
        
        if (!pausing) {
            stopTimer();
        } else {
            continueTimer();
        }
        pausing = !pausing;
        
        refreshDisplay();
    }

    @IBAction func stopClick(sender: UIButton!) {
        
        
        finishLeg();
        stopTimer();
        setDefaults();
        refreshDisplay();
    }
    
    @IBAction func stepperWalkCycleLength(sender : UIStepper!) {
        
        walkCycleLengthSeconds = Int(sender.value);
        
        if (timer == nil) {
            remainingSeconds = walkCycleLengthSeconds;
        }
        refreshDisplay();
    }
    
    @IBAction func stepperRunCycleLength(sender : UIStepper!) {
        
        print(String(format : "%02d",Int(sender.value)) + " value of stepperRunCycleLength " )
        runCycleLengthSeconds = Int(sender.value);
        refreshDisplay();
    }
    
    
    @IBAction func automaticSwitchValueChanged(sender : UISwitch!) {
        
        isAutomatic = sender.on;
        
    }

    func refreshDisplay() {
        
        mapButton?.enabled = legs.count > 0;
        
        if (timer == nil) {
            
            if (!pausing) {
                walkRunButton?.setTitle("Start", forState: UIControlState.Normal)
                walkRunButton?.setTitleColor(UIColor.whiteColor(),forState: UIControlState.Normal)
                walkRunButton?.enabled = true;

                pauseButton?.setTitle("Pause",forState:  UIControlState.Normal);
                pauseButton?.enabled = false;
                
                activityLabel?.text = ""
                activityLabel?.backgroundColor = nil;
                timeCountUpLabel?.text = ""
                
                stopButton?.enabled = false;

            } else {
                pauseButton?.setTitle("Continue",forState:  UIControlState.Normal);
                pauseButton?.enabled = true;
                
                walkRunButton?.enabled = false;
                stopButton?.enabled = true;

 
            }
        }
        else {
            
            walkRunButton?.enabled = true;
            stopButton?.enabled = true;
            
            pauseButton?.setTitle("Pause",forState:  UIControlState.Normal);

            pauseButton?.enabled = true;

            if (running) {
                walkRunButton?.setTitle("Walk", forState: UIControlState.Normal)
                activityLabel?.text = "Running ..."
                activityLabel?.backgroundColor = UIColor.orangeColor();
            } else {
                walkRunButton?.setTitle("Run", forState: UIControlState.Normal)
                activityLabel?.text = "Walking ..."
                activityLabel?.backgroundColor = UIColor.greenColor();
            }
            
            var walkRunBackgroundColor = UIColor.darkGrayColor();
            if (remainingSeconds <= 2) {
                walkRunBackgroundColor = UIColor.whiteColor();
            }
            walkRunButton?.setTitleColor(walkRunBackgroundColor, forState: UIControlState.Normal)
            
            if (remainingSeconds < 0) {
                activityLabel?.textColor = UIColor.redColor();
            } else {
                activityLabel?.textColor = UIColor.whiteColor();
            }
        }
        
        timeCountDownLabel?.text  = ViewController.getTimeString(remainingSeconds);
        
        if (timer != nil || pausing) {
            timeCountUpLabel?.text = ViewController.getTimeString(countUpSeconds);
        }
        
        timeSecondsSumLabel?.text = ViewController.getTimeString(secondsSum);
        
        walkCycleLengthLabel?.text = ViewController.getTimeString(walkCycleLengthSeconds);
        runCycleLengthLabel?.text = ViewController.getTimeString(runCycleLengthSeconds);
        
        sumWalkLabel?.text = "Walk: " + ViewController.getTimeString(sumWalkedSeconds) + " " + String(format : "%.2f", sumWalkedMeters / 1000.0) + " km";
        sumRunLabel?.text = "Run: " + ViewController.getTimeString(sumRunSeconds) + " " + String(format : "%.2f", sumRunMeters / 1000.0) + " km";
        
        tableView.reloadData();
    }
    
    
    func stopTimer() {
        timer?.invalidate();
        timer = nil;
        locationManager.stopUpdatingLocation();
    }
    
    func continueTimer() {

        locationManager.startUpdatingLocation();
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.countdownSeconds), userInfo: nil, repeats: true)
        timer?.fire();

    }

    
    func finishLeg() {
        
        if (currentLeg == nil) {
            return;
        }
        currentLeg!.timeSeconds = countUpSeconds;
        
        if (running) {
            sumRunMeters += currentLeg!.getDistance();
            sumRunSeconds += currentLeg!.timeSeconds;
            remainingSeconds = walkCycleLengthSeconds;
        } else {
            sumWalkedMeters += currentLeg!.getDistance();
            sumWalkedSeconds += currentLeg!.timeSeconds;
            remainingSeconds = runCycleLengthSeconds;
        }
        
        legs.insert(currentLeg!,atIndex: 0);
        currentLeg = nil;
        

    }
    
    func toggleWalkRun() {
        
        if (timer == nil) {
            
            
            continueTimer();
            
            // we empty the list ....
            legs.removeAll();
            
            secondsSum = 0;
            countUpSeconds = 0;

            sumRunMeters = 0;
            sumRunSeconds = 0;

            sumWalkedMeters = 0;
            sumWalkedSeconds = 0;
            
            
        } else {
            
            
            finishLeg();
            
            countUpSeconds = 0;

            running = !running;
        }
        
        currentLeg = WalkRunWalkLeg(firstLocation: currentLocation);
        if (running) {
            currentLeg?.entryType = "Run";
        } else {
            currentLeg?.entryType = "Walk";
        }
        
        locationAtLastToggle = currentLocation;

    }
    
    func countdownSeconds() {
        
        secondsSum += 1;
        remainingSeconds -= 1;
        countUpSeconds += 1;

        if (remainingSeconds == 5) {
            // vibration
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }

        
        if (remainingSeconds == 0) {
            // vibration
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            
            if (isAutomatic) {
                toggleWalkRun();
            }
        }
        
        refreshDisplay();
    }
    
    static func getTimeString(seconds : Int) -> String {
        
        var calcSeconds = seconds;
        if (seconds < 0) {
            calcSeconds = 0;
        }
        let minutes = calcSeconds / 60;
        let restSeconds = calcSeconds - minutes * 60;
        
        let string = String(format: "%02d:%02d",minutes,restSeconds);
        
        return string;
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legs.count;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell  : WalkRunWalkTableCell = tableView.dequeueReusableCellWithIdentifier("walkrunwalktablecell", forIndexPath: indexPath) as! WalkRunWalkTableCell

        let leg : WalkRunWalkLeg = legs[indexPath.row];
        
        cell.entryTypeLabel.text = leg.entryType ;
        cell.timeLabel.text = ViewController.getTimeString(leg.timeSeconds);
        
        
        let velocity : Double = leg.getDistance() / 1000.0 / (Double(leg.timeSeconds) / 60.0 / 60.0);
        
        cell.distLabel.text = String(format: "%.1f", velocity) + " km/h, " + String(format: "%.0f", leg.getDistance()) + " m";
        
        cell.separatorInset = UIEdgeInsetsZero;
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath selected");
        // cell selected code here
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            // manager.startUpdatingLocation()
            // ...
        } else if (status == .NotDetermined) {
            manager.requestWhenInUseAuthorization();
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[locations.count - 1];
        if (currentLeg != nil) {
            currentLeg!.addLocation(currentLocation);
        }
        print("Location-Latitude is " + String(currentLocation!.coordinate.latitude));
        print("Location-Longitude is " + String(currentLocation!.coordinate.longitude));
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error in location Manager " + String(error.localizedDescription));
        
    }
    
}


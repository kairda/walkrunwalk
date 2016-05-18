import Foundation
import UIKit
import AudioToolbox


public class WalkAndRun : NSObject{
    
    var  seconds = 10;
    
    var view : UIView;
    var label : UILabel;
    var buttonStart : UIButton;
    var buttonReset : UIButton;
    var timer : NSTimer?;
    var running : Bool;
    
    
    public init( view: UIView ) {
        
        self.view = view;
        
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 390, height: 200))
        label.font = UIFont(name: "PingFangHK-Ultralight", size: 144)
        label.textColor = UIColor.whiteColor();
        label.center = self.view.center;
        self.view.addSubview(label)
        
        
        let center : CGPoint = self.view.center;
        
        buttonStart = UIButton(frame: CGRect(x: center.x - 90, y: center.y + 50, width: 80, height:100))
        
        buttonStart.setTitle("Start", forState: UIControlState.Normal)
        buttonStart.titleLabel!.font = UIFont(name: "Futura", size: 28)
        self.view.addSubview(buttonStart)
        
        buttonReset = UIButton(frame: CGRect(x: center.x, y: center.y + 50 , width: 80, height:100))
        
        buttonReset.setTitle("Reset", forState: UIControlState.Normal)
        buttonReset.titleLabel!.font = UIFont(name: "Helvetica", size: 28)
        
        self.view.addSubview(buttonReset)
        
        self.running = false;
        
        // prevent the device from going to sleep ...
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        super.init()
        
        buttonStart.addTarget(self, action: #selector(WalkAndRun.onselect), forControlEvents: UIControlEvents.TouchDown)
        
        buttonReset.addTarget(self,action: #selector(WalkAndRun.resetTimer),forControlEvents: UIControlEvents.TouchDown)
        
        timer = nil;
        
        label.text = WalkAndRun.getTimeString(self.seconds);
    }
    
    static func getTimeString(seconds : Int) -> String {
        
        
        let minutes = seconds / 60;
        let restSeconds = seconds - minutes * 60;
        
        let string = String(format: "%02d:%02d",minutes,restSeconds);
        
        return string;
    }
    
    func displayTime() {
        
        self.label.text  = WalkAndRun.getTimeString(self.seconds)
        
    }
    
    func stopTimer() {
        timer?.invalidate();
        timer = nil;
        buttonStart.setTitle("Start", forState: UIControlState.Normal)
        
    }
    func onselect() {
        
        if (running) {
            self.stopTimer();
            
        } else {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(WalkAndRun.update), userInfo: nil, repeats: true)
            timer?.fire()
            buttonStart.setTitle("Stop", forState: UIControlState.Normal)
        }
        
        running = !running;
        
        
    }
    func update() {
        seconds-=1;
        self.displayTime()
        if (seconds == 0) {
            
            self.stopTimer();
            
            // vibration
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
    }
    func resetTimer() {
        seconds = 10;
        self.displayTime();
    }
    func getSeconds() -> Int {
        return seconds;
    }
}

//
//  SampleViewController
//  videoshader
//
//  Created by satoshi on 4/7/15.
//  Copyright (c) 2015 satoshi. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {
    @IBOutlet var ovc : OVLViewController!
    @IBOutlet var labelTime : UILabel!
    @IBOutlet var btnRecord : UIButton!
    
    let notifications = NotificationManager()
    let shaderManager = OVLShaderManager.sharedInstance() as OVLShaderManager
    let scriptNames = ["cartoon", "hawaii", "freeza", "matrix1",
                       "pixelize", "motionblur", "red", "gradientmap",
                       "colorsketch", "delicious", "emboss"]
    lazy var scripts:[OVLScript] = {
        var scripts = [OVLScript]()
        for name in self.scriptNames {
            if let path = NSBundle.mainBundle().pathForResource(name, ofType: "vsscript") {
                if let data = NSData(contentsOfFile:path) {
                    if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                        scripts.append(OVLScript(dictionary: json))
                    }
                }
            }
        }
        return scripts
    }()
    var index:Int = 0 {
        didSet {
            self.ovc.switchScript(scripts[index])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        labelTime.text = ""
        OVLFilter.setFrontCameraMode(true)
        self.ovc.fHD = true
        self.ovc.fps = 30
        self.ovc.fFrontCamera = true
        self.ovc.fPhotoRatio = false

        // Load the script after associated view controllers are fully initialized
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.ovc.loadScript(self.scripts[0])
        }
        
        notifications.addObserverForName(OVLViewController.didUpdateDuration(), object: ovc, queue: nil) { [unowned self] (_ : NSNotification!) -> Void in
            let sec = self.ovc.duration % 60;
            let min = (self.ovc.duration / 60) % 60;
            let hour = self.ovc.duration / 3600;
            self.labelTime.text = NSString(format:"%02d:%02d:%02d", hour, min, sec)
        }
        
        notifications.addObserverForName(OVLViewController.didFinishWritingVideo(), object: ovc, queue: nil) { [unowned self] (_ : NSNotification!) -> Void in

            self.btnRecord.enabled = false
            self.shaderManager.saveMovieToPhotoAlbumAsync(self.ovc.urlVideo) { (assetURL: NSURL!) -> Void in
                self.btnRecord.enabled = true
            }
        }
    }
    
    @IBAction func swiped(sender:UISwipeGestureRecognizer) {
        NSLog("swiped \(sender.direction)")
        if (sender.direction == UISwipeGestureRecognizerDirection.Right) {
            index = (index + 1) % scripts.count
        } else {
            index = (index + scripts.count - 1) % scripts.count
        }
    }
    
    @IBAction func record(sender:UIButton) {
        ovc.record()
        let image = UIImage(named: ovc.fRecording ? "button_video_pressed" : "button_video_normal")
        btnRecord.setImage(image, forState: UIControlState.Normal)
        labelTime.text = ""
    }
}


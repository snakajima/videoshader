//
//  SampleViewController
//  videoshader
//
//  Created by satoshi on 4/7/15.
//  Copyright (c) 2015 satoshi. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController {
    @IBOutlet var ovc : OVLViewController! {
        didSet {
            OVLFilter.setFrontCameraMode(true)
            ovc.fHD = true
            ovc.fps = 30
            ovc.fFrontCamera = fFrontCamera
            ovc.fPhotoRatio = false
        }
    }
    @IBOutlet var labelTime : UILabel! {
        didSet {
            labelTime.text = ""
        }
    }
    @IBOutlet var btnRecord : UIButton!
    @IBOutlet var btnFlip : UIButton!

    // Static members
    let notifications = NotificationManager()
    let shaderManager = OVLShaderManager.sharedInstance() as! OVLShaderManager
    let scriptNames = ["cartoon", "hawaii", "freeza", "matrix1",
                       "pixelize", "motionblur", "red", "gradientmap",
                       "colorsketch", "delicious", "emboss"]
    
    lazy var scripts:[OVLScript] = {
        var scripts = [OVLScript]()
        for name in self.scriptNames {
            
            guard let path = Bundle.main.path(forResource: name, ofType: "vsscript") else {
                continue
            }
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                continue
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSObject : AnyObject] {
                scripts.append(OVLScript(dictionary: json))
            }

        }
        return scripts
    }()

    // Variables members
    var fFrontCamera = false
    var index:Int = 0 {
        didSet {
            self.ovc.switch(scripts[index])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the script after associated view controllers are fully initialized
        DispatchQueue.main.async {
            self.ovc.load(self.scripts[0])
        }

        notifications.addObserverForName(name: OVLViewController.didUpdateDuration(), object: ovc, queue: nil) { [unowned self] (notification) in
            let sec = self.ovc.duration % 60;
            let min = (self.ovc.duration / 60) % 60;
            let hour = self.ovc.duration / 3600;
            self.labelTime.text = NSString(format:"%02d:%02d:%02d", hour, min, sec) as String
        }
        
        
        notifications.addObserverForName(name:  OVLViewController.didFinishWritingVideo(), object: ovc, queue: nil) { [unowned self] (notification) in
            self.btnRecord.isEnabled = false
            self.shaderManager.saveMovie(toPhotoAlbumAsync: self.ovc.urlVideo, callback: { (url) in
                self.btnRecord.isEnabled = true
            })
        }
        
    }
    
    @IBAction func swiped(sender:UISwipeGestureRecognizer) {
        let delta = (sender.direction == UISwipeGestureRecognizerDirection.right) ? 1 : -1
        index = (index + delta + scripts.count) % scripts.count
    }
    
    @IBAction func record(sender:UIButton) {
        ovc.record()
        let image = UIImage(named: ovc.fRecording ? "button_video_pressed" : "button_video_normal")
        btnRecord.setImage(image, for: UIControlState.normal)
        labelTime.text = ""
        btnFlip.isEnabled = !ovc.fRecording
    }
    
    @IBAction func flip(sender:UIButton) {
        fFrontCamera = !fFrontCamera
        OVLFilter.setFrontCameraMode(fFrontCamera)
        self.ovc.updateCameraPosition(fFrontCamera)
    }
}


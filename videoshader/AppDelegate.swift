//
//  AppDelegate.swift
//  videoshader
//
//  Created by satoshi on 4/7/15.
//  Copyright (c) 2015 satoshi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var audioSession:AVAudioSession = {
        let session = AVAudioSession.sharedInstance()
        
        return session
    }()
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try audioSession.setMode(AVAudioSessionModeVideoRecording)
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {}
        return true
    }

}


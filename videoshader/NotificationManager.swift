//
//  NotificationManager.swift
//  backnine
//
//  Created by satoshi on 3/30/15.
//  Copyright (c) 2015 satoshi. All rights reserved.
//

import UIKit

class NotificationManager {
    var observers = [NSObjectProtocol]()
    
    deinit {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func addObserverForName(name: String?, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification!) -> Void) {
        let observer = NSNotificationCenter.defaultCenter().addObserverForName(name, object: obj, queue: queue, usingBlock: block)
        observers.append(observer)
    }
}

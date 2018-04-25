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
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func addObserverForName(name: String?, object obj: AnyObject?, queue: OperationQueue?, usingBlock block: @escaping (Notification??) -> Void) {
        let observer =  NotificationCenter.default.addObserver(forName: name.map { NSNotification.Name(rawValue: $0) }, object: obj, queue: queue, using: block)
        observers.append(observer)
    }
}

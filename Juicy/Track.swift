//
//  Track.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/26/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Track: NSObject {
    
    // MARK: Class Methods
    class func event(name: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            PFAnalytics.trackEvent(name)
        })
    }
    
    class func event(name: String, data: [NSObject : AnyObject]!) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            PFAnalytics.trackEvent(name, dimensions: data)
        })
    }
}
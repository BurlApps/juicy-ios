//
//  Number.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/11/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

extension Int {
    func abbreviate() -> String {
        var num: Float = Float(self)
        var numString: NSString!
        
        if num >= 10e7 {
            num = num / 10e7
            numString =  NSString(format: "%.0fB", num)
        } else if num >= 10e4 {
            num = num / 10e4
            numString =  NSString(format: "%.0fM", num)
        } else if num >= 10e2 {
            num = num / 10e2
            numString =  NSString(format: "%.0fK", num)
        } else {
            numString =  NSString(format: "%.0f", num)
        }
        
        return numString
    }
}
//
//  String.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/20/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}
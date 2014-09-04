//
//  Array.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/18/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import Foundation

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
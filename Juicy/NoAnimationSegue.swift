//
//  NoAnimationSegue.swift
//  Juicy
//
//  Created by Brian Vallelunga on 8/4/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

@objc(NoAnimationSegue)
class NoAnimationSegue: UIStoryboardSegue {
    override func perform () {
        let source = self.sourceViewController as UIViewController
        let destination = self.destinationViewController as UIViewController
        source.navigationController.pushViewController(destination, animated:false)
    }
}

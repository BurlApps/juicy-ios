//
//  Settings.swift
//  Juicy
//
//  Created by Brian Vallelunga on 9/22/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

class Settings: NSObject {
    
    // MARK: Instance Variables
    var host: String!
    var abDefault: String!
    var abTesting: Bool!
    var backgrounds: [UIColor] = []
    var parse: PFConfig!
    
    // MARK: Convenience Methods
    convenience init(_ settings: PFConfig) {
        self.init()
        
        self.host = settings["host"] as String
        self.abDefault = settings["abDefault"] as String
        self.abTesting = settings["abTesting"] as Bool
        self.parse = settings
        
        for (name, background) in settings["backgrounds"] as [String: [CGFloat]] {
            let red = background[0]/255
            let green = background[1]/255
            let blue = background[2]/255
            
            self.backgrounds.append(UIColor(red: red, green: green, blue: blue, alpha: 1))
        }
    }
    
    // MARK: Class Methods
    class func sharedInstance(callback: ((settings: Settings) -> Void)!) {
        if let config = PFConfig.currentConfig() {
            callback?(settings: Settings(config))
        } else {
            Settings.update(callback)
        }
    }
    
    class func update(callback: ((settings: Settings) -> Void)!) {
        PFConfig.getConfigInBackgroundWithBlock { (config: PFConfig!, error: NSError!) -> Void in
            if error == nil && config != nil {
                callback?(settings: Settings(config))
            } else if var config = PFConfig.currentConfig() {
                callback?(settings: Settings(config))
            }
        }
    }
    
    // MARK: Instance Methods
    func tester(user: User) -> String {
        if self.abTesting == true {
            return user.abTester
        } else {
            return self.abDefault
        }
    }
}

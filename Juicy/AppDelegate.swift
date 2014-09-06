
//
//  AppDelegate.swift
//  Juicy
//
//  Created by Brian Vallelunga on 6/15/14.
//  Copyright (c) 2014 Brian Vallelunga. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        let infoDictionary = NSBundle.mainBundle().infoDictionary;
        
        //Initialize Parse
        let parseApplicationID = infoDictionary["ParseApplicationID"] as  NSString
        let parseClientKey = infoDictionary["ParseClientKey"] as  NSString
        Parse.setApplicationId(parseApplicationID, clientKey: parseClientKey)
        
        //Initialize Facebook
        PFFacebookUtils.initializeFacebook()
        
        // Initialize NewRelic
        let newRelicKey = infoDictionary["NewRelicKey"] as  NSString
        NewRelicAgent.startWithApplicationToken(newRelicKey)

        // Initialize HockeyApp
        let hockeyAppKey = infoDictionary["HockeyAppKey"] as  NSString
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(hockeyAppKey)
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        BITHockeyManager.sharedHockeyManager().testIdentifier()

        // Return 
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString, annotation: AnyObject) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session())
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {        
        var installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject("termsChanged", forKey: "channels")
        installation.addUniqueObject("juicyPost", forKey: "channels")
        installation.addUniqueObject("juicyUser", forKey: "channels")
        installation.addUniqueObject("sharedPost", forKey: "channels")
        installation.saveInBackground()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        PFQuery.clearAllCachedResults()
    }
}



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
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Initialize BugSnag
        let bugSnagKey = infoDictionary["BugSnagKey"] as NSString
        Bugsnag.startBugsnagWithApiKey(bugSnagKey)
        
        // Initialize NewRelic
        let newRelicKey = infoDictionary["NewRelicKey"] as NSString
        NewRelicAgent.startWithApplicationToken(newRelicKey)
        
        //Initialize Parse
        let parseApplicationID = infoDictionary["ParseApplicationID"] as NSString
        let parseClientKey = infoDictionary["ParseClientKey"] as  NSString
        Parse.setApplicationId(parseApplicationID, clientKey: parseClientKey)
        
        //Initialize Facebook
        PFFacebookUtils.initializeFacebook()
        
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector(Selector("registerUserNotificationSettings:")) {
            let notificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        
        // Register for Push Notifications before iOS 8
        } else {
            let notificationTypes = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(notificationTypes)
        }
        
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload = (launchOptions?.objectForKey(UIApplicationLaunchOptionsRemoteNotificationKey) == nil)
            
            if preBackgroundPush || oldPushHandlerOnly || noPushPayload {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        // Update Settings
        Settings.update(nil)
        
        // Configure Settings Panel
        let version = infoDictionary["CFBundleShortVersionString"] as NSString
        let build = infoDictionary[kCFBundleVersionKey] as NSString
        let versionBuild = "\(version) (\(build))" as NSString
        let previousVersionBuild = userDefaults.objectForKey("VersionNumber") as? NSString
        
        if versionBuild != previousVersionBuild {
            User.logout()
        }
        
        userDefaults.setValue(versionBuild, forKey: "VersionNumber")
        userDefaults.synchronize()

        // Return 
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString, annotation: AnyObject) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, withSession:PFFacebookUtils.session())
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] as NSString
        let build = infoDictionary[kCFBundleVersionKey] as NSString
        var installation = PFInstallation.currentInstallation()
        
        installation.setDeviceTokenFromData(deviceToken)
        installation.addUniqueObject("termsChanged", forKey: "channels")
        installation.addUniqueObject("juicyPost", forKey: "channels")
        installation.addUniqueObject("juicyUser", forKey: "channels")
        installation.addUniqueObject("sharedPost", forKey: "channels")
        installation.setObject("\(version) - \(build)", forKey: "appVersionBuild")
        installation.saveInBackground()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
        
        var installation = PFInstallation.currentInstallation()
        installation.badge = 0
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)

        if application.applicationState == UIApplicationState.Inactive {
            // The application was just brought from the background to the foreground,
            // so we consider the app as having been "opened by a push notification."
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplicationState.Inactive {
            // The application was just brought from the background to the foreground,
            // so we consider the app as having been "opened by a push notification."
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            Post.batchSave(force: true)
            Track.batchSave(force: true)
        })
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            Post.batchSave(force: true)
            Track.batchSave(force: true)
        })
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            PFQuery.clearAllCachedResults()
        })
    }
}


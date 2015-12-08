//
//  AppDelegate.swift
//  Artfull
//
//  Created by Joseph Kiley on 12/2/15.
//  Copyright © 2015 Joseph Kiley. All rights reserved.
//

import UIKit
import CoreData
import UIKit
import Parse
import ParseFacebookUtilsV4
import Bolts
import InstagramKit
import UberRides

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawerContainer: MMDrawerController?
    
    // FUNC : DIDFINISHLAUNCHINGWITHOPTIONS
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Parse Optional
        // Parse.enableLocalDatastore()
        // ParseCrashReporting.enable()
        
        // Parse Initialize
        Parse.setApplicationId("NwfeOFg0eLVrJEi4zsFLous4ZPzUYL7B2gOSuaRA",
            clientKey: "p9vcVAjUpf5uVtEHldTVIbvHgTb6dnTsa1ov6VjZ")
        
        // Parse Facebook
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // Parse Analytics
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // Push Notifications
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        // PARSE Analytics - Tracking push notifications effect
        if application.applicationState != UIApplicationState.Background
        {
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        // set up Uber
        RidesClient.sharedInstance.configureClientID("gGwcouSmBOM_XouAiUHox3soE3Uhq8WB")
        
        // Get User location Using Parse
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                // do something with the new geoPoint
            }
        }
        
        buildUserInterface()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { (success, error) -> Void in
            print("Registration successful? \(success)")
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
    {
        print("Failed to register \(error.localizedDescription)")
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
    {
        PFPush.handlePush(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func applicationDidBecomeActive(application: UIApplication)
    {
        FBSDKAppEvents.activateApp()
    }
    
    // FUNC : BUILD USER INTERFACE
    func buildUserInterface()
    {
        let userName:String? =  NSUserDefaults.standardUserDefaults().stringForKey("user_name")
        
        if(userName != nil)
        {
            // Navigate to Protected page
            let mainStoryBoard:UIStoryboard = UIStoryboard(name:"main", bundle:nil)
            
            // Create View Controllers
            let mainPage:MainPageViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("MainPageViewController") as! MainPageViewController
            
            let leftSideMenu:LeftSideViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LeftSideViewController") as! LeftSideViewController
            
            // Wrap into Navigation controllers
            let mainPageNav = UINavigationController(rootViewController:mainPage)
            let leftSideMenuNav = UINavigationController(rootViewController:leftSideMenu)
            
            drawerContainer = MMDrawerController(centerViewController: mainPageNav, leftDrawerViewController: leftSideMenuNav)
            drawerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
            drawerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
            window?.rootViewController = drawerContainer
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        return true
        
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        return true
        
    }
}


//
//  AppDelegate.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 09.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	static let LocationAccessAuthorizationChangedNotification = "LocationAccessAuthorizationChangedNotification"
	static let LocationAccessAuthorizationChangedKey = "LocationAccessAuthorizationChangedKey"
	
	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		if let window = window {
			window.tintColor = UIColor.colorWithWebColor("#0092a8", alpha: 1.0)
		}
		UserDefaults.prepareDefaultSettings()
		return true
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

	let locationManager = CLLocationManager.init()

	func applicationDidBecomeActive(application: UIApplication) {
		locationManager.delegate = self
		
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		} else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
			showAuthorizeAlert()
		} else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
			postAuthorizationNotificationWithStatus(CLLocationManager.authorizationStatus())
		}
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	private func showAuthorizeAlert() {
		let alertController = UIAlertController(title: LocalizedString("helphelp2.accessLocation.title"), message: LocalizedString("helphelp2.accessLocation.text"), preferredStyle: UIAlertControllerStyle.Alert)
		let settingsAction = UIAlertAction(title: LocalizedString("helphelp2.accessLocation.action.settings"), style: UIAlertActionStyle.Default) { (action) -> Void in
			UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
		}
		alertController.addAction(settingsAction)
		window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
	}

	private func postAuthorizationNotificationWithStatus(status:CLAuthorizationStatus) {
		NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.LocationAccessAuthorizationChangedNotification, object: self, userInfo: [AppDelegate.LocationAccessAuthorizationChangedKey:Int(status.rawValue)])
	}

}

// MARK: - CLLocationManager Delegate

extension AppDelegate : CLLocationManagerDelegate {
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.AuthorizedWhenInUse  ||
			CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
			postAuthorizationNotificationWithStatus(status)
		}
	}
}


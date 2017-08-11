//
//  AppDelegate.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 09.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit
import CoreLocation


extension Notification.Name {
	static let locationAccessAuthorizationChangedNotification = Notification.Name("LocationAccessAuthorizationChangedNotification")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	static let LocationAccessAuthorizationChangedKey = "LocationAccessAuthorizationChangedKey"

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		if let window = window {
			window.tintColor = UIColor.colorWithWebColor("#0092a8", alpha: 1.0)
		}
		HHUserDefaults.prepareDefaultSettings()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary
		// interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your
		// application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	let locationManager = CLLocationManager.init()

	func applicationDidBecomeActive(_ application: UIApplication) {
		locationManager.delegate = self

		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
			locationManager.requestWhenInUseAuthorization()
		} else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
			showAuthorizeAlert()
		} else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
			postAuthorizationNotificationWithStatus(CLLocationManager.authorizationStatus())
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	private func showAuthorizeAlert() {
		let alertController = UIAlertController(title: "Standort",
		                                        message: "Sie müssen den Zugriff auf Ihren Standort erlauben, um diese App zu benutzen.",
		                                        preferredStyle: UIAlertControllerStyle.alert)
		let settingsAction = UIAlertAction(title: "Einstellungen", style: UIAlertActionStyle.default) { (_) -> Void in
			UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
		}
		alertController.addAction(settingsAction)
		window?.rootViewController?.present(alertController, animated: true, completion: nil)
	}

	fileprivate func postAuthorizationNotificationWithStatus(_ status: CLAuthorizationStatus) {
		NotificationCenter.default.post(name: .locationAccessAuthorizationChangedNotification,
		                                object: self,
		                                userInfo: [AppDelegate.LocationAccessAuthorizationChangedKey: Int(status.rawValue)])
	}

}

// MARK: - CLLocationManager Delegate

extension AppDelegate : CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedWhenInUse  ||
			CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
			postAuthorizationNotificationWithStatus(status)
		}
	}
}

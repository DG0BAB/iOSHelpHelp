//
//  ListViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 09.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController {
	
	@IBOutlet weak var heartContainerView: UIView!
	@IBOutlet weak var textView: UITextView!
	
	private lazy var locationManager:CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		locationManager.distanceFilter = UserDefaults.distanceFilter()
		return locationManager
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.contentInset = UIEdgeInsets(top: heartContainerView.bounds.size.height, left: 0, bottom: 0, right: 0)
		CollectionSiteManager.reset()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
			self.locationManager.startUpdatingLocation()
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		self.locationManager.stopUpdatingLocation()
	}
	
	private func loadSitesData() {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = NSTextAlignment.Center
		
		if let orderedSites = CollectionSiteManager.currentManager?.orderedSites {
			let attributedText = NSMutableAttributedString(string: "", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])

			for collectionSite in orderedSites {
				attributedText.appendAttributedString(NSAttributedString(string: "\(collectionSite.name)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName : UIColor.colorWithWebColor("#a0388c", alpha: 1.0)!]))
				
				let distance = String(format: "%2.2f", (collectionSite.distance/1000))
				attributedText.appendAttributedString(NSAttributedString(string: "\n"+"Entfernung: "+distance+" km", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				if collectionSite.helpersNeeded {
					attributedText.appendAttributedString(NSAttributedString(string: "\nFreiwillige Helfer gesucht!", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : UIColor.colorWithWebColor("#a0388c", alpha: 1.0)!]))
				}
				let itemString = collectionSite.itemsAsString
				if !itemString.isEmpty {
					attributedText.appendAttributedString(NSAttributedString(string: "\n", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
					attributedText.appendAttributedString(NSAttributedString(string: "\n\(itemString)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				}
				
				attributedText.appendAttributedString(NSAttributedString(string: "\n\n\(collectionSite.address.street)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				attributedText.appendAttributedString(NSAttributedString(string: "\n\(collectionSite.address.zip)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				attributedText.appendAttributedString(NSAttributedString(string: " \(collectionSite.address.city)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				if !collectionSite.contact.isEmpty {
					attributedText.appendAttributedString(NSAttributedString(string: "\n\nKontakt: \(collectionSite.contact)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				}
				if !collectionSite.webAddress.isEmpty {
					attributedText.appendAttributedString(NSAttributedString(string: "\nWebseite: \(collectionSite.webAddress)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				}
				if !collectionSite.openingHint.isEmpty {
					attributedText.appendAttributedString(NSAttributedString(string: "\nWeitere Angaben: \(collectionSite.openingHint)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
				}
				attributedText.appendAttributedString(NSAttributedString(string: "\n\n----------\n\n", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSParagraphStyleAttributeName : centerParagraphStyle]))
				textView.attributedText = attributedText
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension ListViewController : CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let userLocation = locations.last {
			CollectionSiteManager.loadSitesForCoordinate(userLocation.coordinate, urlString: "https://helphelp2.com") { siteManager in self.loadSitesData() }
		}
	}
}

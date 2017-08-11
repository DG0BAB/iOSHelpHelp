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
	@IBOutlet weak var listTabBarItem: UITabBarItem!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	private lazy var locationManager: CLLocationManager = {
		let locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		locationManager.distanceFilter = HHUserDefaults.distanceFilter()
		return locationManager
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		listTabBarItem.title = NSLocalizedString("helphelp2.mainNavigation.list", comment: "")
		textView.contentInset = UIEdgeInsets(top: heartContainerView.bounds.size.height, left: 0, bottom: 0, right: 0)
		CollectionSiteManager.reset()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
			self.locationManager.startUpdatingLocation()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.locationManager.stopUpdatingLocation()
	}

	private func loadSitesData() {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = NSTextAlignment.center

		if let orderedSites = CollectionSiteManager.currentManager?.orderedSites {
			let attributedText = NSMutableAttributedString(string: "", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)])

			for collectionSite in orderedSites {
				attributedText.append(NSAttributedString(string: "\(collectionSite.name)",
					attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17),
					             NSAttributedStringKey.foregroundColor : UIColor.colorWithWebColor("#a0388c", alpha: 1.0)!]))

				let distance = String(format: "%2.2f", (collectionSite.distance/1000))
				attributedText.append(NSAttributedString(string:
					"""
					\n\(NSLocalizedString("helphelp2.siteAnnotation.distance", comment:""))
					\(distance) \(NSLocalizedString("helphelp2.siteAnnotation.distance.unit", comment: ""))
					""",
					attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				if collectionSite.helpersNeeded {
					attributedText.append(NSAttributedString(string: "\n\(NSLocalizedString("helphelp2.siteDetail.list.helpersNeeded", comment:""))",
						attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
						             NSAttributedStringKey.foregroundColor : UIColor.colorWithWebColor("#a0388c", alpha: 1.0)!]))
				}
				let itemString = collectionSite.itemsAsString
				if !itemString.isEmpty {
					attributedText.append(NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
					attributedText.append(NSAttributedString(string: "\n\(itemString)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				}

				attributedText.append(NSAttributedString(string: "\n\n\(collectionSite.address.street)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				attributedText.append(NSAttributedString(string: "\n\(collectionSite.address.zip)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				attributedText.append(NSAttributedString(string: " \(collectionSite.address.city)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				if !collectionSite.contact.isEmpty {
					attributedText.append(NSAttributedString(string: "\n\n\(NSLocalizedString("helphelp2.siteDetail.list.contact", comment: "")) \(collectionSite.contact)",
						attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				}
				if !collectionSite.webAddress.isEmpty {
					attributedText.append(NSAttributedString(string: "\n\(NSLocalizedString("helphelp2.siteDetail.list.webAddress", comment: "")) \(collectionSite.webAddress)",
						attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				}
				if !collectionSite.openingHint.isEmpty {
					attributedText.append(NSAttributedString(string: "\n\(NSLocalizedString("helphelp2.siteDetail.list.more", comment: "")) \(collectionSite.openingHint)",
						attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
				}
				attributedText.append(NSAttributedString(string: "\n\n----------\n\n",
				                                         attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15),
				                                                      NSAttributedStringKey.paragraphStyle : centerParagraphStyle]))
				textView.attributedText = attributedText
			}
		}
	}

	override func didReceiveMemoryWarning() {
		URLCache.shared.removeAllCachedResponses()
		super.didReceiveMemoryWarning()
	}
}

extension ListViewController : CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let userLocation = locations.last {
			CollectionSiteManager.loadSitesForCoordinate(userLocation.coordinate, urlString: "https://helphelp2.com") { _ in self.loadSitesData() }
		}
	}
}

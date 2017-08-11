//
//  MapViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 09.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

	static let CollectionSiteAnnotationIdentifier = "CollectionSiteAnnotation"

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var locateUserButton: UIButton!
	fileprivate var startRegion: MKCoordinateRegion?
	private var currentAnnotations = Set<CollectionSiteAnnotation>()

	fileprivate var isAuthorized = false {
		didSet {
			if isAuthorized != oldValue {
				prepareMapView()
			}
		}
	}
	fileprivate var isRendered = false {
		didSet {
			if isRendered != oldValue {
				if startRegion == nil {
					startRegion = mapView.region
				}
				prepareMapView()
			}
	}
}

// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		NotificationCenter.default.addObserver(self, selector:  #selector(authorizationStatusChanged(notification:)), name: .locationAccessAuthorizationChangedNotification, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}


// MARK: - Notifications

	@objc func authorizationStatusChanged(notification: Notification) {
		if let userInfo = notification.userInfo,
			let rawStatus = userInfo[AppDelegate.LocationAccessAuthorizationChangedKey] as? Int32 {
			let status = CLAuthorizationStatus(rawValue: rawStatus)
			isAuthorized = status == CLAuthorizationStatus.authorizedWhenInUse
		}
	}

// MARK: - Actions

	func infoButtonAction(annotationView: MKAnnotationView, control: UIControl) {
		if let navigationContoller = self.storyboard?.instantiateViewController(withIdentifier: "CollectionSiteMapDetailNavigationViewController") as? UINavigationController {
			if let detailViewController = navigationContoller.topViewController as? CollectionSiteMapDetailViewController,
				let siteId = (annotationView.annotation as? CollectionSiteAnnotation)?.siteId {
				detailViewController.siteId = siteId

				if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
					detailViewController.modalPresentationStyle = UIModalPresentationStyle.pageSheet
					detailViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
					present(navigationContoller, animated: true, completion: nil)
				} else {
					let popoverController = UIPopoverController(contentViewController: navigationContoller)
					popoverController.present(from: control.frame, in: annotationView, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
				}
			}
		}
	}

	@IBAction func locateUserAction(sender: AnyObject) {
		firstZoom = true
		potentiallyZoomToUserLocation(mapView.userLocation)
	}

// MARK: - Overrides From Superclass

	override func didReceiveMemoryWarning() {
		URLCache.shared.removeAllCachedResponses()
		super.didReceiveMemoryWarning()
	}

// MARK: - Private Stuff

	private func prepareMapView() {
		if isAuthorized && isRendered {
			mapView.showsUserLocation = true
			mapView.userTrackingMode = .follow
			locateUserButton.isEnabled = true
		} else {
			mapView.showsUserLocation = false
			mapView.userTrackingMode = .none
			locateUserButton.isEnabled = false
			CollectionSiteManager.reset()
			firstZoom = true
		}
	}


	private var firstZoom = true
	fileprivate func potentiallyZoomToUserLocation(_ userLocation: MKUserLocation) {
		if firstZoom {
			if let coordinateRegion = CollectionSiteManager.currentManager?.coordinateRegionForNearestSiteToLocation(userLocation) {
				mapView.setRegion(coordinateRegion, animated: true)
				firstZoom = false
			}
		}

	}
	fileprivate func showSiteAnnotationsInRegion(_ region: MKCoordinateRegion) {
		if let sitesWithinRegion = CollectionSiteManager.currentManager?.sitesWithinRegion(region) {
			self.prepareAnnotationsForSites(sitesWithinRegion)
		}
	}

	private func prepareAnnotationsForSites(_ sites: CollectionSitesType) {
		if isAuthorized && isRendered {
			var newAnnotations = Set<CollectionSiteAnnotation>()
			for oneSite in sites {
				if let coordinate = CollectionSiteManager.currentManager?.coordinateForSite(oneSite) {
					let anotation = CollectionSiteAnnotation(siteId: oneSite.id)
					anotation.coordinate = coordinate
					anotation.title = oneSite.name
					let distance = String(format: "%2.2f", (oneSite.distance/1000))
					anotation.subtitle = "Entfernung: "+distance+" km"
					newAnnotations.insert(anotation)
				}
			}
			let annotationsToRemnove = currentAnnotations.subtracting(newAnnotations)
			newAnnotations = currentAnnotations.subtracting(annotationsToRemnove)
			let annotationsToAdd = newAnnotations.subtracting(currentAnnotations)
			newAnnotations = newAnnotations.union(annotationsToAdd)
			if currentAnnotations != newAnnotations {
				mapView.removeAnnotations(Array(annotationsToRemnove))
				mapView.addAnnotations(Array(annotationsToAdd))
				currentAnnotations = newAnnotations
			}
		} else {
			for oneAnnotation in mapView.annotations {
				mapView.removeAnnotation(oneAnnotation)
			}
			self.currentAnnotations.removeAll()
		}
	}
}


// MARK: - MAPViewController Delegate

extension MapViewController : MKMapViewDelegate {

	func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
		if let region = startRegion, (mode == MKUserTrackingMode.none && (!isRendered || !isAuthorized)) {
			mapView.region = region
		}
	}

	func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
		isRendered = fullyRendered
	}

	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		CollectionSiteManager.loadSitesForCoordinate(userLocation.coordinate, urlString: "https://helphelp2.com") { _ in self.potentiallyZoomToUserLocation(userLocation) }
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		showSiteAnnotationsInRegion(mapView.region)
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		guard !(annotation is MKUserLocation) else { return nil }

		var pinAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier:MapViewController.CollectionSiteAnnotationIdentifier) as? MKPinAnnotationView

		if pinAnnotation == nil {
			pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: MapViewController.CollectionSiteAnnotationIdentifier)
			pinAnnotation!.pinColor = MKPinAnnotationColor.red
			pinAnnotation!.animatesDrop = true
			pinAnnotation!.canShowCallout = true
			let infoButton = UIButton(type: UIButtonType.detailDisclosure)
			pinAnnotation!.rightCalloutAccessoryView = infoButton
		} else {
			pinAnnotation?.annotation = annotation
		}
		return pinAnnotation
	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		infoButtonAction(annotationView: view, control: control)
	}

}

// MARK: - MKCoordinateRegion Extension

extension MKCoordinateRegion {
	func metersOfLatitude() -> CLLocationDistance {
		//get latitude-span in meters
		let loc1 = CLLocation(latitude: center.latitude-span.latitudeDelta*0.5, longitude: center.longitude)
		let loc2 = CLLocation(latitude: center.latitude+span.latitudeDelta*0.5, longitude: center.longitude)
		return loc1.distance(from: loc2)
	}

	func metersOfLongitude() -> CLLocationDistance {
		//get longitude-span in meters
		let loc1 = CLLocation(latitude: center.latitude, longitude: center.longitude-span.longitudeDelta*0.5)
		let loc2 = CLLocation(latitude: center.latitude, longitude: center.longitude+span.longitudeDelta*0.5)
		return loc1.distance(from: loc2)
	}

}

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
	private var startRegion: MKCoordinateRegion?
	private var currentAnnotations = Set<CollectionSiteAnnotation>()
	
	private var isAuthorized = false {
		didSet {
			if isAuthorized != oldValue {
				prepareMapView()
			}
		}
	}
	private var isRendered = false {
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
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "authorizationStatusChanged:", name: AppDelegate.LocationAccessAuthorizationChangedNotification, object: nil)
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


// MARK: - Notifications
	
	func authorizationStatusChanged(notification:NSNotification) {
		if let userInfo = notification.userInfo {
			let status = CLAuthorizationStatus.init(rawValue: Int32((userInfo[AppDelegate.LocationAccessAuthorizationChangedKey] as! Int)))
			isAuthorized = status == CLAuthorizationStatus.AuthorizedWhenInUse
		}
	}
	
// MARK: - Actions
	
	func infoButtonAction(annotationView:MKAnnotationView, control:UIControl) {
		if let navigationContoller = self.storyboard?.instantiateViewControllerWithIdentifier("CollectionSiteMapDetailNavigationViewController") as? UINavigationController {
			if let detailViewController = navigationContoller.topViewController as? CollectionSiteMapDetailViewController {
				detailViewController.siteId = (annotationView.annotation as! CollectionSiteAnnotation).siteId
				
				if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
					detailViewController.modalPresentationStyle = UIModalPresentationStyle.PageSheet
					detailViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
					presentViewController(navigationContoller, animated: true, completion: nil)
				} else {
					let popoverController = UIPopoverController(contentViewController: navigationContoller)
					popoverController.presentPopoverFromRect(control.frame, inView: annotationView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
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
		NSURLCache.sharedURLCache().removeAllCachedResponses()
		super.didReceiveMemoryWarning()
	}

// MARK:- Private Stuff
	
	private func prepareMapView() {
		if isAuthorized && isRendered {
			mapView.showsUserLocation = true
			mapView.userTrackingMode = .Follow
			locateUserButton.enabled = true
		} else {
			mapView.showsUserLocation = false
			mapView.userTrackingMode = .None
			locateUserButton.enabled = false
			CollectionSiteManager.reset()
			firstZoom = true
		}
	}
	
	
	private var firstZoom = true
	private func potentiallyZoomToUserLocation(userLocation:MKUserLocation) {
		if firstZoom {
			if let coordinateRegion = CollectionSiteManager.currentManager?.coordinateRegionForNearestSiteToLocation(userLocation) {
				mapView.setRegion(coordinateRegion, animated: true)
				firstZoom = false
			}
		}

	}
	private func showSiteAnnotationsInRegion(region:MKCoordinateRegion) {
		if let sitesWithinRegion = CollectionSiteManager.currentManager?.sitesWithinRegion(region) {
			self.prepareAnnotationsForSites(sitesWithinRegion)
		}
	}
	
	private func prepareAnnotationsForSites(sites:CollectionSitesType) {
		if isAuthorized && isRendered {
			var newAnnotations = Set<CollectionSiteAnnotation>()
			for oneSite in sites {
				if let coordinate = CollectionSiteManager.currentManager?.coordinateForSite(oneSite) {
					let anotation = CollectionSiteAnnotation(siteId: oneSite.id)
					anotation.coordinate = coordinate
					anotation.title = oneSite.name
					let distance = String(format: "%2.2f", (oneSite.distance/1000))
					anotation.subtitle = "Entfernung: "+distance+" km"
					newAnnotations.insert(anotation);
				}
			}
			let annotationsToRemnove = currentAnnotations.subtract(newAnnotations)
			let annotationsToAdd = newAnnotations.subtract(currentAnnotations)
			newAnnotations = currentAnnotations.subtract(annotationsToRemnove)
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

	func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
		if let region = startRegion where mode == MKUserTrackingMode.None && (!isRendered || !isAuthorized){
			mapView.region = region
		}
	}
	
	func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
		isRendered = fullyRendered
	}
	
	func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
		CollectionSiteManager.loadSitesForCoordinate(userLocation.coordinate, urlString: "https://helphelp2.com") { siteManager in self.potentiallyZoomToUserLocation(userLocation) }
	}

	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		showSiteAnnotationsInRegion(mapView.region)
	}
	
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		
		guard !(annotation is MKUserLocation) else { return nil }
		
		var pinAnnotation = mapView.dequeueReusableAnnotationViewWithIdentifier(MapViewController.CollectionSiteAnnotationIdentifier) as? MKPinAnnotationView
		
		if pinAnnotation == nil {
			pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: MapViewController.CollectionSiteAnnotationIdentifier)
			pinAnnotation!.pinColor = MKPinAnnotationColor.Red
			pinAnnotation!.animatesDrop = true
			pinAnnotation!.canShowCallout = true
			let infoButton = UIButton(type: UIButtonType.DetailDisclosure)
			pinAnnotation!.rightCalloutAccessoryView = infoButton
		} else {
			pinAnnotation?.annotation = annotation
		}
		return pinAnnotation
	}
	
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		infoButtonAction(view, control: control)
	}
	
}

// MARK: - MKCoordinateRegion Extension

extension MKCoordinateRegion {
	func metersOfLatitude() -> CLLocationDistance {
		//get latitude-span in meters
		let loc1 = CLLocation(latitude: center.latitude-span.latitudeDelta*0.5, longitude: center.longitude)
		let loc2 = CLLocation(latitude: center.latitude+span.latitudeDelta*0.5, longitude: center.longitude)
		return loc1.distanceFromLocation(loc2)
	}

	func metersOfLongitude() -> CLLocationDistance {
		//get longitude-span in meters
		let loc1 = CLLocation(latitude: center.latitude, longitude: center.longitude-span.longitudeDelta*0.5)
		let loc2 = CLLocation(latitude: center.latitude, longitude: center.longitude+span.longitudeDelta*0.5)
		return loc1.distanceFromLocation(loc2)
	}

	
}

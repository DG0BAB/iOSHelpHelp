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
	private var startRegion: MKCoordinateRegion?
	private var currentLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
	private var currentRegion:MKCoordinateRegion?
	private var currentAnnotations = Set<CollectionSiteAnnotation>()
	
	private lazy var locationManager:CLLocationManager = {
		let locationManager = CLLocationManager.init()
		locationManager.delegate = self
		locationManager.distanceFilter = 10000
		return locationManager
	}()
	
// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		startRegion = mapView.region
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "authorizationStatusChanged:", name: AppDelegate.LocationAccessAuthorizationChangedNotification, object: nil)
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		locationManager.stopUpdatingLocation()
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func authorizationStatusChanged(notification:NSNotification) {
		if let userInfo = notification.userInfo {
			let status = CLAuthorizationStatus.init(rawValue: Int32((userInfo[AppDelegate.LocationAccessAuthorizationChangedKey] as! Int)))
			if status == CLAuthorizationStatus.AuthorizedWhenInUse {
				prepareMapView()
			} else {
				locationManager.stopUpdatingLocation()
				mapView.region = startRegion!
				for oneAnnotation in mapView.annotations {
					mapView.removeAnnotation(oneAnnotation)
				}
			}
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
		potentiallyZoomToUserLocation()
	}
	
// MARK: - Overrides From Superclass
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

// MARK:- Private Stuff
	
	private func prepareMapView() {
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .Follow
		if !firstZoom {
			firstZoom = true
			potentiallyZoomToUserLocation()
		}
	}
	
	private var firstZoom = true
	
	private func potentiallyZoomToUserLocation() {
		if firstZoom {
			let coordinateRegion = UserDefaults.defaultCoordinateRegion(currentLocation.coordinate)
			mapView.setRegion(coordinateRegion, animated: true)
			showSiteAnnotationsInRegion(coordinateRegion)
			firstZoom = false
		}

	}
	private func showSiteAnnotationsInRegion(region:MKCoordinateRegion) {
		if let sitesWithinRegion = CollectionSiteManager.currentManager?.sitesWithinRegion(region) {
			self.prepareAnnotations(sitesWithinRegion)
		}
	}
	
	private func prepareAnnotations(sites:CollectionSitesType) {
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
		mapView.removeAnnotations(Array(annotationsToRemnove))
		mapView.addAnnotations(Array(annotationsToAdd))
		currentAnnotations = newAnnotations
	}
}

// MARK: - CLLocationManager Delegate

extension MapViewController : CLLocationManagerDelegate {
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if let userLocation = locations.last where currentLocation.distanceFromLocation(userLocation) > locationManager.distanceFilter{
			self.currentLocation = userLocation
			CollectionSiteManager.loadSitesForCoordinate(userLocation.coordinate) { siteManager in self.potentiallyZoomToUserLocation() }
		}
	}
	
}

// MARK: - MAPViewController Delegate

extension MapViewController : MKMapViewDelegate {
	
	func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
		self.locationManager.startUpdatingLocation()
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
	
	func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		currentRegion = mapView.region
		if currentRegion?.center.latitude != startRegion?.center.latitude {
			showSiteAnnotationsInRegion(currentRegion!)
		}

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

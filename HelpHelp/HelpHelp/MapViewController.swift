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
	var currentLocation:CLLocation = CLLocation(latitude: 0, longitude: 0)
	
	private lazy var locationManager:CLLocationManager = {
		let locationManager = CLLocationManager.init()
		locationManager.delegate = self
		locationManager.distanceFilter = 10000
		return locationManager
	}()
	
// MARK: - View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		} else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
			prepareMapView()
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		locationManager.stopUpdatingLocation()
	}

// MARK: - Actions
	
	func infoButtonAction(annotation:CollectionSiteAnnotation, control:UIControl) {
		if let detailViewController = self.storyboard?.instantiateViewControllerWithIdentifier(CollectionSiteMapDetailViewController.Identifier) as? CollectionSiteMapDetailViewController {
			detailViewController.siteId = annotation.siteId
			
			if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
				detailViewController.modalPresentationStyle = UIModalPresentationStyle.PageSheet
				detailViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
				presentViewController(detailViewController, animated: true, completion: nil)
			} else {
				let popoverController = UIPopoverController(contentViewController: detailViewController)
				popoverController.presentPopoverFromRect(control.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
			}
		}
	}
	
// MARK: - Overrides From Superclass
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

// MARK:- Private Stuff
	
	private func prepareMapView() {
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .Follow
		mapView.delegate = self
	}
	
	private func prepareAnnotations(sites:CollectionSitesType) {
		for oneSite in sites {
			if let coordinate = CollectionSiteManager.currentManager?.coordinateForSite(oneSite) {
				let anotation = CollectionSiteAnnotation(siteId: oneSite.id)
				anotation.coordinate = coordinate
				anotation.title = oneSite.name
				let distance = String(format: "%2.2f", (oneSite.distance/1000))
				anotation.subtitle = "Entfernung: "+distance+" km"
				mapView.addAnnotation(anotation);
			}
		}
		
	}
}

// MARK: - CLLocationManager Delegate

extension MapViewController : CLLocationManagerDelegate {
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.Denied {
			// TODO: Show Error and Exit
		} else if status == CLAuthorizationStatus.AuthorizedWhenInUse {
			prepareMapView()
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let userLocation = locations.last where currentLocation.distanceFromLocation(userLocation) > locationManager.distanceFilter {
			self.currentLocation = userLocation
			let coordinateRegion = UserDefaults.defaultCoordinateRegion(userLocation.coordinate)
			mapView.setRegion(coordinateRegion, animated: true)
			
			CollectionSiteManager.loadSitesForCoordinate(userLocation.coordinate) { [unowned self] siteManager in
				let sitesWithinRegion = siteManager.sitesWithinDistance(coordinateRegion.metersOfLatitude())
				self.prepareAnnotations(sitesWithinRegion)
			}
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
//			infoButton.addTarget(self, action: "infoButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
			pinAnnotation!.rightCalloutAccessoryView = infoButton
		} else {
			pinAnnotation?.annotation = annotation
		}
		return pinAnnotation
	}
	
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		infoButtonAction(view.annotation as! CollectionSiteAnnotation, control: control)
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

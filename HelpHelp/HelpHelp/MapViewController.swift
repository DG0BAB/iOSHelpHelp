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

	@IBOutlet weak var mapView: MKMapView!
	
	private lazy var locationManager:CLLocationManager = {
		let locationManager = CLLocationManager.init()
		locationManager.delegate = self
		locationManager.distanceFilter = 1000
		return locationManager
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .Follow
		mapView.delegate = self
		if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
			locationManager.requestWhenInUseAuthorization()
		}
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		locationManager.stopUpdatingLocation()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension MapViewController : CLLocationManagerDelegate {
	
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.Denied {
			// TODO: Show Error and Exit
		}
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let userLocation = locations.last {
			let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 20000, 20000)
			self.mapView.setRegion(coordinateRegion, animated: true)
		}
	}
	
}

extension MapViewController : MKMapViewDelegate {
	
	func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
		self.locationManager.startUpdatingLocation()
	}
}
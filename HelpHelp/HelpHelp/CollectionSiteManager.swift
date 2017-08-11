//
//  CollectionSiteManager.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 13.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit.MKGeometry

typealias SitesLoadingCompletionType = (CollectionSiteManager) -> Void

class CollectionSiteManager {

	static var currentManager: CollectionSiteManager?
	private static var currentCoordinate: CLLocationCoordinate2D?
	private static var lastUpdate: Date?
	private static var communicator: HTTPCommunicator?

	class func loadSitesForCoordinate(_ coordinate: CLLocationCoordinate2D, urlString: String, completion: SitesLoadingCompletionType? = nil) {

		var shouldLoad = false

		if let currentCoordinate = self.currentCoordinate {
			if  currentCoordinate.distanceFromCoordinate(coordinate) > HHUserDefaults.distanceFilter() {
				shouldLoad = true
			} else if let lastUpdate = self.lastUpdate {
				if Date().timeIntervalSince(lastUpdate) > 10.minutes {
					shouldLoad = true
				}
			}
		} else {
			shouldLoad = true
		}

		guard shouldLoad else { return }

		if let communicator = HTTPCommunicator(urlString: urlString) {
			self.communicator = communicator
			do {
				try communicator.GET(path: "/heart/places?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", success: { (resultData) -> Void in
					do {
						if let jsonDict = try JSONSerialization.jsonObject(with: resultData, options: [JSONSerialization.ReadingOptions.allowFragments]) as? JSONDictType {
							let container = CollectionSiteContainer(jsonDict: jsonDict)
							currentManager = CollectionSiteManager(container: container)
							self.currentCoordinate = coordinate
							self.lastUpdate = Date()
							print("Sites read")
							DispatchQueue.main.async {
								completion?(currentManager!)
							}
							self.communicator = nil
						}
					} catch {

					}
					}, failure: { (error) -> Void in
						print("Fehler: \(error)")
				})
			} catch HTTPCommunicatorError.missingPath {
				print("No Path given for GET")
			} catch {
				print("Unbekannter Fehler")
			}
		}
	}

	class func reset() {
		currentCoordinate = nil
		currentManager = nil
	}

	let collectionSiteContainer: CollectionSiteContainer
	var orderedSites: [CollectionSite]? {
		return collectionSiteContainer.collectionSites.sorted(by: {$0.distance < $1.distance})
	}

	required init(container: CollectionSiteContainer) {
		self.collectionSiteContainer = container
	}

	func siteForId(_ siteId: Int) -> CollectionSite? {
		if let index = collectionSiteContainer.collectionSites.index(where: {(site) -> Bool in return siteId == site.id}) {
			return collectionSiteContainer.collectionSites[index]
		}
		return nil
	}

	func nearestSite() -> CollectionSite? {
		return orderedSites?.first
	}

	func sitesWithinRegion(_ region: MKCoordinateRegion?) -> CollectionSitesType! {
		if let region = region {
			return CollectionSitesType(collectionSiteContainer.collectionSites.filter { (site) -> Bool in
				let deltaLat = abs(standardAngle(region.center.latitude - site.address.latitude))
				let deltalong = abs(standardAngle(region.center.longitude - site.address.longitude))
				return region.span.latitudeDelta >= deltaLat && region.span.longitudeDelta >= deltalong
				})
		} else {
			return CollectionSitesType()
		}
	}

	func coordinateForSite(_ site: CollectionSite) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: site.address.latitude, longitude: site.address.longitude)
	}

	func coordinateRegionForNearestSiteToLocation(_ location: MKUserLocation) -> MKCoordinateRegion {
		if let nearestSite = nearestSite() {
			return MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(fabs(nearestSite.address.latitude-location.coordinate.latitude)*2.7,
			                                                                        fabs(nearestSite.address.longitude-location.coordinate.longitude)*2.7))
		} else {
			return HHUserDefaults.defaultCoordinateRegion(location: location.coordinate)
		}
	}

	/// Standardises and angle to [-180 to 180] degrees
	private func standardAngle(_ angle: CLLocationDegrees) -> CLLocationDegrees {
		let angle = angle.truncatingRemainder(dividingBy: 360.0)
		return angle < -180 ? -360 - angle : angle > 180 ? 360 - 180 : angle
	}

}

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
	
	static var currentManager:CollectionSiteManager?
	private static var currentCoordinate:CLLocationCoordinate2D?
	private static var lastUpdate:NSDate?
	private static var communicator:HTTPCommunicator?
	
	class func loadSitesForCoordinate(coordinate:CLLocationCoordinate2D, urlString:String, completion:SitesLoadingCompletionType? = nil) {
		
		var shouldLoad = false
		
		if let currentCoordinate = self.currentCoordinate {
			if  currentCoordinate.distanceFromCoordinate(coordinate) > UserDefaults.distanceFilter() {
				shouldLoad = true
			} else if let lastUpdate = self.lastUpdate {
				if NSDate().timeIntervalSinceDate(lastUpdate) > 10.minutes {
					shouldLoad = true
				}
			}
		} else {
			shouldLoad = true
		}
		
		guard shouldLoad else { return }
		
		if let communicator = HTTPCommunicator(url:urlString) {
			self.communicator = communicator
			do {
				try communicator.GET("/heart/places?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)",
					success: { (resultData) -> Void in
						do {
							let jsonDict = try NSJSONSerialization.JSONObjectWithData(resultData, options: NSJSONReadingOptions.AllowFragments) as! JSONDictType
							let container = CollectionSiteContainer(jsonDict: jsonDict)
							currentManager = CollectionSiteManager(container: container)
							self.currentCoordinate = coordinate
							self.lastUpdate = NSDate()
							print("Sites read")
							dispatch_async(dispatch_get_main_queue()) {
								completion?(currentManager!)
							}
							self.communicator = nil
						} catch {
							
						}
					},
					failure: { (error) -> Void in
						print("Fehler: \(error)")
				})
			} catch HTTPCommunicatorError.MissingPath {
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
	
	let collectionSiteContainer:CollectionSiteContainer
	var orderedSites:[CollectionSite]?
	
	required init(container:CollectionSiteContainer) {
		self.collectionSiteContainer = container
		orderedSites = collectionSiteContainer.collectionSites.sort({$0.distance < $1.distance})
	}
	
	func siteForId(siteId:Int) -> CollectionSite? {
		if let index = collectionSiteContainer.collectionSites.indexOf({(site) -> Bool in return siteId == site.id}) {
			return collectionSiteContainer.collectionSites[index]
		}
		return nil
	}
	
	func nearestSite() -> CollectionSite? {
		return orderedSites?.first
	}
	
	func sitesWithinRegion(region:MKCoordinateRegion?) -> CollectionSitesType! {
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
	
	func coordinateForSite(site:CollectionSite) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: site.address.latitude, longitude: site.address.longitude)
	}
	
	func coordinateRegionForNearestSiteToLocation(location:MKUserLocation) -> MKCoordinateRegion {
		if let nearestSite = nearestSite() {
			return MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(fabs(nearestSite.address.latitude-location.coordinate.latitude)*2.7, fabs(nearestSite.address.longitude-location.coordinate.longitude)*2.7))
		} else {
			return UserDefaults.defaultCoordinateRegion(location.coordinate)
		}
	}
	
	/// Standardises and angle to [-180 to 180] degrees
	private func standardAngle(var angle: CLLocationDegrees) -> CLLocationDegrees {
		angle %= 360
		return angle < -180 ? -360 - angle : angle > 180 ? 360 - 180 : angle
	}

}

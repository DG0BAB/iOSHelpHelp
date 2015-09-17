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
	static var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	
	class func loadSitesForCoordinate(coordinate:CLLocationCoordinate2D, completion:SitesLoadingCompletionType? = nil) {
		
		self.currentLocation = coordinate
		let communicator = HTTPCommunicator(url:"https://helphelp2.com")
		
		do {
			try communicator?.GET("/heart/places/?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", success: { (resultData) -> Void in
				do {
					let jsonDict = try NSJSONSerialization.JSONObjectWithData(resultData, options: NSJSONReadingOptions.AllowFragments) as! JSONDictType
					let container = CollectionSiteContainer(jsonDict: jsonDict)
					currentManager = CollectionSiteManager(container: container)
					print("Sites read")
					completion?(currentManager!)
				} catch {
					
				}
				}, failure: { (error) -> Void in
					print("Fehler: \(error)")
			})
		} catch HTTPCommunicatorError.MissingPath {
			print("No Path given for GET")
		} catch {
			print("Unbekannter Fehler")
		}
	}
	
	let collectionSiteContainer:CollectionSiteContainer
	
	required init(container:CollectionSiteContainer) {
		self.collectionSiteContainer = container
	}
	
	func siteForId(siteId:Int) -> CollectionSite? {
		if let index = collectionSiteContainer.collectionSites.indexOf({(site) -> Bool in return siteId == site.id}) {
			return collectionSiteContainer.collectionSites[index]
		}
		return nil
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
	
	/// Standardises and angle to [-180 to 180] degrees
	private func standardAngle(var angle: CLLocationDegrees) -> CLLocationDegrees {
		angle %= 360
		return angle < -180 ? -360 - angle : angle > 180 ? 360 - 180 : angle
	}

}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs:CLLocationCoordinate2D, rhs:CLLocationCoordinate2D) -> Bool {
	return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
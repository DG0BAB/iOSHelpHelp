//
//  CollectionSiteManager.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 13.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation
import CoreLocation

typealias SitesLoadingCompletionType = (CollectionSiteManager) -> Void

class CollectionSiteManager {
	
	static var currentManager:CollectionSiteManager?
	static var currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	
	class func loadSitesForCoordinate(coordinate:CLLocationCoordinate2D, completion:SitesLoadingCompletionType?) {
		
		guard let completion = completion else { return }
		
		self.currentLocation = coordinate
		let communicator = HTTPCommunicator(url:"https://helphelp2.com")
		
		do {
			try communicator?.GET("/heart/places/?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", success: { (resultData) -> Void in
				do {
					let jsonDict = try NSJSONSerialization.JSONObjectWithData(resultData, options: NSJSONReadingOptions.AllowFragments) as! JSONDictType
					let container = CollectionSiteContainer(jsonDict: jsonDict)
					currentManager = CollectionSiteManager(container: container)
					print("Sites read")
					completion(currentManager!)
				} catch {
					
				}
				}, failure: { (error) -> Void in
					print("Fehler: \(error)")
			})
		} catch HTTPCommunicatorError.MissingPath {
			print("No Path given for GET")
		} catch {
			
		}
	}
	
	let collectionSiteContainer:CollectionSiteContainer
	
	required init(container:CollectionSiteContainer) {
		self.collectionSiteContainer = container
	}
	
	func sitesWithinDistance(distance:CLLocationDistance) -> CollectionSitesType {
		return collectionSiteContainer.collectionSites.filter { (site) -> Bool in
			site.distance <= distance
		}
	}
	
	func coordinateForSite(site:CollectionSite) -> CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: site.address.latitude, longitude: site.address.longitude)
	}
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs:CLLocationCoordinate2D, rhs:CLLocationCoordinate2D) -> Bool {
	return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
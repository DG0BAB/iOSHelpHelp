//
//  UserDefaults.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 13.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit.MKGeometry

class UserDefaults {
	
	private enum DefaultName : String {
		case DistanceFilter
		case CoordinateRegion
	}
	
	private static var userDefaults:NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}
	
	class func prepareDefaultSettings() {
		let defaultSettings = [DefaultName.DistanceFilter.rawValue:10000]
		userDefaults.registerDefaults(defaultSettings)
	}
	
	class func distanceFilter() -> CLLocationDistance {
		return userDefaults.doubleForKey(DefaultName.DistanceFilter.rawValue)
	}
	
	class func setDistanceFilter(distance:CLLocationDistance) {
		userDefaults.setDouble(distance, forKey: DefaultName.DistanceFilter.rawValue)
	}
	
	class func coordinateRegion() -> MKCoordinateRegion? {
		if let centerValue = userDefaults.valueForKey(DefaultName.CoordinateRegion.rawValue+"Center") {
			let coordinateCenter = centerValue.MKCoordinateValue
			let spanValue = userDefaults.valueForKey(DefaultName.CoordinateRegion.rawValue+"Span")!
			let coordinateSpan = spanValue.MKCoordinateSpanValue
			return MKCoordinateRegion(center: coordinateCenter, span: coordinateSpan)
		}
		return nil
	}
	
	class func setCoordinateRegion(coordinateRegion:MKCoordinateRegion) {
		userDefaults.setValue(NSValue(MKCoordinate:coordinateRegion.center), forKey: DefaultName.CoordinateRegion.rawValue+"Center")
		userDefaults.setValue(NSValue(MKCoordinateSpan:coordinateRegion.span), forKey: DefaultName.CoordinateRegion.rawValue+"Span")
	}
	
	class func defaultCoordinateRegion(location:CLLocationCoordinate2D) -> MKCoordinateRegion {
		return MKCoordinateRegionMakeWithDistance(location, distanceFilter()*2, distanceFilter()*2)
	}
}
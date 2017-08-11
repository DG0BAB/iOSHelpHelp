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

class HHUserDefaults {

	private enum DefaultName: String {
		case distanceFilter
		case coordinateRegion
	}

	private static var userDefaults: UserDefaults {
		return UserDefaults.standard
	}

	class func prepareDefaultSettings() {
		let defaultSettings = [DefaultName.distanceFilter.rawValue:10000]
		userDefaults.register(defaults: defaultSettings)
	}

	class func distanceFilter() -> CLLocationDistance {
		return userDefaults.double(forKey: DefaultName.distanceFilter.rawValue)
	}

	class func setDistanceFilter(distance: CLLocationDistance) {
		userDefaults.set(distance, forKey: DefaultName.distanceFilter.rawValue)
	}

	class func coordinateRegion() -> MKCoordinateRegion? {
		if let centerValue = userDefaults.value(forKey: DefaultName.coordinateRegion.rawValue+"Center") as? NSValue,
			let spanValue = userDefaults.value(forKey: DefaultName.coordinateRegion.rawValue+"Span") as? NSValue {
			let coordinateCenter = centerValue.mkCoordinateValue
			let coordinateSpan = spanValue.mkCoordinateSpanValue
			return MKCoordinateRegion(center: coordinateCenter, span: coordinateSpan)
		}
		return nil
	}

	class func setCoordinateRegion(coordinateRegion: MKCoordinateRegion) {
		userDefaults.setValue(NSValue(mkCoordinate:coordinateRegion.center), forKey: DefaultName.coordinateRegion.rawValue+"Center")
		userDefaults.setValue(NSValue(mkCoordinateSpan:coordinateRegion.span), forKey: DefaultName.coordinateRegion.rawValue+"Span")
	}

	class func defaultCoordinateRegion(location: CLLocationCoordinate2D) -> MKCoordinateRegion {
		return MKCoordinateRegionMakeWithDistance(location, distanceFilter()*2, distanceFilter()*2)
	}
}

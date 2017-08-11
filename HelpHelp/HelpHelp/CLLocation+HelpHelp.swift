//
//  CLLocation+HelpHelp.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 19.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
	func distanceFromCoordinate(_ coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
		return CLLocation(latitude: self.latitude, longitude: self.longitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
	}
}

extension CLLocationCoordinate2D: Equatable {}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
	return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

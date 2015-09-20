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
	func distanceFromCoordinate(coordinate:CLLocationCoordinate2D) -> CLLocationDistance {
		return CLLocation(latitude: self.latitude, longitude: self.longitude).distanceFromLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
	}
}
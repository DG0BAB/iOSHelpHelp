//
//  Address.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

class Address {
	let latitude:Double
	let longitude:Double
	let street:String
	let zip:String
	let city:String
	
	required init(latitude:Double, longitude:Double, street:String?, zip:String?, city:String?) {
		self.latitude = latitude
		self.longitude = longitude
		self.street = street ?? ""
		self.zip = zip ?? ""
		self.city = city ?? ""
	}
	
	convenience init(jsonDict:JSONDictType) {
		let latitude = jsonDict["lat"] as! Double
		let longitude = jsonDict["lon"] as! Double
		let street = jsonDict["street"] as? String
		let zip = jsonDict["zip"] as? String
		let city = jsonDict["city"] as?String
		self.init(latitude:latitude, longitude:longitude, street:street, zip:zip, city:city)
	}
}
//
//  CollectionSite.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

/*
struct Weekday : OptionSetType {
	let rawValue : Int
	static let Monday = Weekday(rawValue: 1 << 1)
	static let Tuesday = Weekday(rawValue: 1 << 2)
	static let Wednesday = Weekday(rawValue: 1 << 3)
	static let Thursday = Weekday(rawValue: 1 << 4)
	static let Friday = Weekday(rawValue: 1 << 5)
	static let Saturday = Weekday(rawValue: 1 << 6)
	static let Sunday = Weekday(rawValue: 1 << 7)
}
*/

struct CollectionSite: Equatable {
	
	let id:Int
	let name:String
	let address:Address
	let openingHint:String
	let webAddress:String
	let contactPerson:String
	let contactPhoneNumber:String
	let helpersNeeded:Bool
	let items:[String]
	
/*
	struct OpeningHours {
		let fromTime:NSTimeInterval
		let toTime:NSTimeInterval
		let days:Weekday
		
		init(days:Weekday, fromTime:NSTimeInterval, toTime:NSTimeInterval) {
			self.days = days
			self.fromTime = fromTime
			self.toTime = toTime
		}
		
		init?(humanReadableString:String) {
			guard humanReadableString.isEmpty else { return nil }
			
		}
	}
*/
	init(id:Int, name:String, address:Address, openingHint:String, webAddress:String, contactPerson:String, contactPhoneNumber:String, helpersNeeded:Bool, items:[String]) {
		self.id = id
		self.name = name
		self.address = address
		self.openingHint = openingHint
		self.webAddress = webAddress
		self.contactPerson = contactPerson
		self.contactPhoneNumber = contactPhoneNumber
		self.helpersNeeded = helpersNeeded
		self.items = items
	}
	
	init(jsonDict:JSONDictType) {
		let id = jsonDict["id"] as! Int
		let name = jsonDict["name"] as! String
		let address = Address(jsonDict:jsonDict["addr"] as! JSONDictType)
		let openingHint = jsonDict["hours"] as! String
		let webAddress = jsonDict["website"] as! String
		let contactPerson = jsonDict["person"] as! String
		let contactPhoneNumber = jsonDict["phone"] as! String
		let helpersNeeded = jsonDict["helpers"] as! Bool
		self.init(id:id, name:name, address:address, openingHint:openingHint, webAddress:webAddress, contactPerson:contactPerson, contactPhoneNumber:contactPhoneNumber, helpersNeeded:helpersNeeded, items:[String]())
	}
}

func ==(lhs: CollectionSite, rhs: CollectionSite) -> Bool {
	return lhs.id == rhs.id
	}


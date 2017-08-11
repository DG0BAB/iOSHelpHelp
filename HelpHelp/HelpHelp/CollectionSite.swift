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

class CollectionSite: Equatable {

	let id: Int
	let name: String
	let address: Address
	let distance: Double
	let openingHint: String
	let webAddress: String
	let contactPerson: String
	let contactPhoneNumber: String
	let helpersNeeded: Bool
	let items: [String]

	var contact: String {
		let person = contactPerson.isEmpty ? "" : contactPerson
		let plus = (!contactPerson.isEmpty && !contactPhoneNumber.isEmpty) ?  ", " : ""
		let phone = contactPhoneNumber.isEmpty ? "" : contactPhoneNumber
		return person+plus+phone
	}

	var itemsAsString: String {
		return (items as NSArray).componentsJoined(by: ", ")
	}

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
	required init(id: Int, name: String, address: Address, distance: Double, openingHint: String, webAddress: String,
	              contactPerson: String, contactPhoneNumber: String, helpersNeeded: Bool, items: [String]) {
		self.id = id
		self.name = name
		self.address = address
		self.distance = distance
		self.openingHint = openingHint
		self.webAddress = webAddress
		self.contactPerson = contactPerson
		self.contactPhoneNumber = contactPhoneNumber
		self.helpersNeeded = helpersNeeded
		self.items = items
	}

	convenience init?(jsonDict: JSONDictType) {
		guard let id = jsonDict["id"] as? Int,
			let name = jsonDict["name"] as? String,
			let addressDict = jsonDict["addr"] as? JSONDictType,
			let address = Address(jsonDict: addressDict),
			let distance = jsonDict["distance"] as? Double,
			let openingHint = jsonDict["hours"] as? String,
			let webAddress = jsonDict["website"] as? String,
			let contactPerson = jsonDict["person"] as? String,
			let contactPhoneNumber = jsonDict["phone"] as? String,
			let helpersNeeded = jsonDict["helpers"] as? Bool,
			let items = jsonDict["items"] as? [String]  else {
				return nil
		}
		self.init(id:id, name:name, address:address, distance:distance, openingHint:openingHint, webAddress:webAddress, contactPerson:contactPerson,
		          contactPhoneNumber:contactPhoneNumber, helpersNeeded:helpersNeeded, items:items)
	}

}

func == (lhs: CollectionSite, rhs: CollectionSite) -> Bool {
	return lhs === rhs
}

extension CollectionSite : Hashable {
	var hashValue: Int {
		return id
	}
}

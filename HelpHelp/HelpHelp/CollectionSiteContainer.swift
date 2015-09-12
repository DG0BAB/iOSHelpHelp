//
//  CollectionSiteContainer.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

typealias JSONDictType = [String:AnyObject]
typealias CollectionSitesType = [CollectionSite]

class CollectionSiteContainer: NSObject {
	static let CollectionSitesKVOKey = "CollectionSites"
	
	private lazy var mutableCollectionSites:CollectionSitesType = {
		return CollectionSitesType()
	}()
	
	var collectionSites: CollectionSitesType {
		let result = mutableCollectionSites
		return result
	}
	
	init(jsonDict:JSONDictType) {
		super.init()
		let sites = jsonDict["places"] as! [JSONDictType]
		for oneEntry in sites {
			let newSite = CollectionSite(jsonDict: oneEntry)
			addSite(newSite)
		}
	}
	
	func addSite(site:CollectionSite) {
		willChangeValueForKey(CollectionSiteContainer.CollectionSitesKVOKey)
		mutableCollectionSites.append(site)
		didChangeValueForKey(CollectionSiteContainer.CollectionSitesKVOKey)
	}
	
	func removeSite(site:CollectionSite) {
		if let index = indexOfSite(site) {
			willChangeValueForKey(CollectionSiteContainer.CollectionSitesKVOKey)
			mutableCollectionSites.removeAtIndex(index)
			didChangeValueForKey(CollectionSiteContainer.CollectionSitesKVOKey)
		}
	}
	
	func indexOfSite(site:CollectionSite) -> Int? {
		return mutableCollectionSites.indexOf(site)
	}
}
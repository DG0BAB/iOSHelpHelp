//
//  CollectionSiteContainer.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

typealias JSONDictType = [String : Any]
typealias CollectionSitesType = Set<CollectionSite>

class CollectionSiteContainer: NSObject {
	static let CollectionSitesKVOKey = "CollectionSites"

	private lazy var mutableCollectionSites: CollectionSitesType = {
		return CollectionSitesType()
	}()

	var collectionSites: CollectionSitesType {
		let result = mutableCollectionSites
		return result
	}

	init(jsonDict: JSONDictType) {
		super.init()
		if let sites = jsonDict["places"] as? [JSONDictType] {
			for oneEntry in sites {
				if let newSite = CollectionSite(jsonDict: oneEntry) {
					addSite(newSite)
				}
			}
		}
	}

	func addSite(_ site: CollectionSite) {
		willChangeValue(forKey: CollectionSiteContainer.CollectionSitesKVOKey)
		mutableCollectionSites.insert(site)
		didChangeValue(forKey: CollectionSiteContainer.CollectionSitesKVOKey)
	}

	func removeSite(_ site: CollectionSite) {
		willChangeValue(forKey: CollectionSiteContainer.CollectionSitesKVOKey)
		mutableCollectionSites.remove(site)
		didChangeValue(forKey: CollectionSiteContainer.CollectionSitesKVOKey)
	}

	func indexOfSite(_ site: CollectionSite) -> SetIndex<CollectionSite>? {
		return mutableCollectionSites.index(of: site)
	}
}

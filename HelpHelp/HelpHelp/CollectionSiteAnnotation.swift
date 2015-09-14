//
//  CollectionSiteAnnotation.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 14.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation
import MapKit

class CollectionSiteAnnotation: MKPointAnnotation {
	var siteId:Int = 0
	
	required init(siteId:Int) {
		super.init()
		self.siteId = siteId
	}
}
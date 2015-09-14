//
//  CollectionSiteMapDetailViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 14.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit

class CollectionSiteMapDetailViewController: UIViewController {
	
	static var Identifier:String { return (NSStringFromClass(self) as NSString).pathExtension }

	@IBOutlet weak var siteNameLabel: UILabel!
	@IBOutlet weak var openingHintLabel: UILabel!
	@IBOutlet weak var contactLabel: UILabel!
	
	var siteId:Int = -1
	var collectionSite:CollectionSite?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionSite = (CollectionSiteManager.currentManager?.siteForId(siteId))!
		siteNameLabel.text = collectionSite!.name
		openingHintLabel.text = collectionSite!.openingHint
	}
}
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
	@IBOutlet weak var contactValueLabel: UILabel!
	@IBOutlet weak var helpersWanted: UILabel!
	@IBOutlet weak var itemsTextView: UITextView!
	@IBOutlet weak var shadowLineImageView: UIImageView!
	@IBOutlet weak var closeButton: UIBarButtonItem!
	
	var siteId:Int = -1
	var collectionSite:CollectionSite?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if var image = shadowLineImageView.image {
			image = image .imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			shadowLineImageView.image = image
			shadowLineImageView.tintColor = UIColor.PurpleColor
		}
		
		if navigationController?.modalPresentationStyle == UIModalPresentationStyle.Popover {
			self.navigationItem.rightBarButtonItem = nil
		} else {
			self.navigationItem.rightBarButtonItem = closeButton
		}
		
		if let collectionSite = (CollectionSiteManager.currentManager?.siteForId(siteId)) {
			siteNameLabel.text = collectionSite.name
			openingHintLabel.text = collectionSite.openingHint
			contactLabel.text = collectionSite.contact.isEmpty ? "" : "Kontakt:"
			contactValueLabel.text = collectionSite.contact.isEmpty ? "" : collectionSite.contact
			helpersWanted.text = collectionSite.helpersNeeded ? "Freiwillige Helfer gesucht!" : ""
			itemsTextView.text = collectionSite.itemsAsString
		}
	}
	
	@IBAction func closeButtonAction(sender: AnyObject) {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func addressButtonAction(sender: AnyObject) {
		if let addressViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("CollectionSiteAddressViewController") as? CollectionSiteAddressViewController) {
			addressViewController.siteId = siteId
			self.navigationController?.pushViewController(addressViewController, animated: true)
		}
	}
}
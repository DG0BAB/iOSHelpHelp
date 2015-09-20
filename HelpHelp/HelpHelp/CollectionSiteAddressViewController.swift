//
//  CollectionSiteAddressViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 17.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit

class CollectionSiteAddressViewController : UIViewController {
	
	@IBOutlet weak var closeButton: UIBarButtonItem!
	@IBOutlet weak var addressTextView: UITextView!
	
	var siteId:Int = -1
	
	override func viewDidLoad() {
		
		if navigationController?.modalPresentationStyle == UIModalPresentationStyle.Popover {
			self.navigationItem.rightBarButtonItem = nil
		} else {
			self.navigationItem.rightBarButtonItem = closeButton
		}
		
		if let collectionSite = (CollectionSiteManager.currentManager?.siteForId(siteId)) {
			let attributedText = NSMutableAttributedString(string: collectionSite.name, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])
			attributedText.appendAttributedString(NSAttributedString(string: "\n\n\(collectionSite.address.street)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			attributedText.appendAttributedString(NSAttributedString(string: "\n\(collectionSite.address.zip)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			attributedText.appendAttributedString(NSAttributedString(string: " \(collectionSite.address.city)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			if !collectionSite.contact.isEmpty {
				attributedText.appendAttributedString(NSAttributedString(string: "\n\nKontakt: \(collectionSite.contact)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			}
			if !collectionSite.webAddress.isEmpty {
				attributedText.appendAttributedString(NSAttributedString(string: "\n\nWebseite: \(collectionSite.webAddress)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			}
			if !collectionSite.openingHint.isEmpty {
				attributedText.appendAttributedString(NSAttributedString(string: "\n\nWeitere Angaben: \(collectionSite.openingHint)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			}
			addressTextView.attributedText = attributedText
		}
	}
	@IBAction func closeButtonAction(sender: AnyObject) {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
}
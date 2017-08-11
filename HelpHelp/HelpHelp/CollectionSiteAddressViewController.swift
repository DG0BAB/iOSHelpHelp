//
//  CollectionSiteAddressViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 17.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit

class CollectionSiteAddressViewController: UIViewController {

	@IBOutlet weak var closeButton: UIBarButtonItem!
	@IBOutlet weak var addressTextView: UITextView!

	var siteId: Int = -1

	override func viewDidLoad() {

		if navigationController?.modalPresentationStyle == UIModalPresentationStyle.popover {
			self.navigationItem.rightBarButtonItem = nil
		} else {
			self.navigationItem.rightBarButtonItem = closeButton
		}

		if let collectionSite = (CollectionSiteManager.currentManager?.siteForId(siteId)) {
			let attributedText = NSMutableAttributedString(string: collectionSite.name, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize:15)])
			attributedText.append(NSAttributedString(string: "\n\n\(collectionSite.address.street)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize:15)]))
			attributedText.append(NSAttributedString(string: "\n\(collectionSite.address.zip)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize:15)]))
			attributedText.append(NSAttributedString(string: " \(collectionSite.address.city)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize:15)]))
			if !collectionSite.contact.isEmpty {
				attributedText.append(NSAttributedString(string: "\n\nKontakt: \(collectionSite.contact)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize:15)]))
			}
			if !collectionSite.webAddress.isEmpty {
				attributedText.append(NSAttributedString(string: "\n\nWebseite: \(collectionSite.webAddress)",
					attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize:15)]))
			}
			if !collectionSite.openingHint.isEmpty {
				attributedText.append(NSAttributedString(string: "\n\nWeitere Angaben: \(collectionSite.openingHint)",
					attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize:15)]))
			}
			addressTextView.attributedText = attributedText
		}
	}
	@IBAction func closeButtonAction(sender: AnyObject) {
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}
}

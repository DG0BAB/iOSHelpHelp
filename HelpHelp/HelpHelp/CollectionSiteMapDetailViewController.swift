//
//  CollectionSiteMapDetailViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 14.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit

class CollectionSiteMapDetailViewController: UIViewController {

	static var Identifier: String { return (NSStringFromClass(self) as NSString).pathExtension }

	@IBOutlet weak var siteNameLabel: UILabel!
	@IBOutlet weak var openingHintLabel: UILabel!
	@IBOutlet weak var helpersWanted: UILabel!
	@IBOutlet weak var itemsTextView: UITextView!
	@IBOutlet weak var shadowLineImageView: UIImageView!
	@IBOutlet weak var closeButton: UIBarButtonItem!
	@IBOutlet weak var shadowLineAddressImageView: UIImageView!
	@IBOutlet weak var addressTextView: UITextView!

	var siteId: Int = -1
	private var collectionSite: CollectionSite?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		if var image = shadowLineImageView.image {
			image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			shadowLineImageView.image = image
			shadowLineImageView.tintColor = UIColor.PurpleColor
			shadowLineAddressImageView.image = image
			shadowLineAddressImageView.tintColor = UIColor.PurpleColor
		}

		if navigationController?.modalPresentationStyle == UIModalPresentationStyle.popover {
			self.navigationItem.rightBarButtonItem = nil
		} else {
			self.navigationItem.rightBarButtonItem = closeButton
		}

		self.collectionSite = (CollectionSiteManager.currentManager?.siteForId(siteId))

		if let collectionSite = self.collectionSite {
			siteNameLabel.text = collectionSite.name
			openingHintLabel.text = collectionSite.openingHint
			helpersWanted.text = collectionSite.helpersNeeded ? "Freiwillige Helfer gesucht!" : ""
			itemsTextView.text = collectionSite.itemsAsString
		}

		if let collectionSite = self.collectionSite {
			let attributedText = NSMutableAttributedString(string: collectionSite.address.street,
			                                               attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)])
			attributedText.append(NSAttributedString(string: "\n\(collectionSite.address.zip)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
			attributedText.append(NSAttributedString(string: " \(collectionSite.address.city)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
			if !collectionSite.contact.isEmpty {
				attributedText.append(NSAttributedString(string: "\n\nKontakt: \(collectionSite.contact)",
														 attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
			}
			if !collectionSite.webAddress.isEmpty {
				attributedText.append(NSAttributedString(string: "\nWebseite: \(collectionSite.webAddress)",
														 attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
			}
			if !collectionSite.openingHint.isEmpty {
				attributedText.append(NSAttributedString(string: "\nWeitere Angaben: \(collectionSite.openingHint)",
														 attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
			}
			addressTextView.attributedText = attributedText
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupTextViews()
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: nil) { (_) -> Void in
			self.setupTextViews()
		}
	}

	@IBAction func closeButtonAction(sender: AnyObject) {
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}

	@IBAction func addressButtonAction(sender: AnyObject) {
		if let addressViewController = (self.storyboard?.instantiateViewController(withIdentifier: "CollectionSiteAddressViewController") as? CollectionSiteAddressViewController) {
			addressViewController.siteId = siteId
			self.navigationController?.pushViewController(addressViewController, animated: true)
		}
	}

	private func setupTextViews() {
		itemsTextView.scrollRangeToVisible(NSRange(0..<0))
		addressTextView.scrollRangeToVisible(NSRange(0..<0))
	}
}

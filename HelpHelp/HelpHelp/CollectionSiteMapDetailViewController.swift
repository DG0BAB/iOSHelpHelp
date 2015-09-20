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
	@IBOutlet weak var helpersWanted: UILabel!
	@IBOutlet weak var itemsTextView: UITextView!
	@IBOutlet weak var shadowLineImageView: UIImageView!
	@IBOutlet weak var closeButton: UIBarButtonItem!
	@IBOutlet weak var shadowLineAddressImageView: UIImageView!
	@IBOutlet weak var addressTextView: UITextView!
	
	var siteId:Int = -1
	private var collectionSite:CollectionSite?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if var image = shadowLineImageView.image {
			image = image .imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			shadowLineImageView.image = image
			shadowLineImageView.tintColor = UIColor.PurpleColor
			shadowLineAddressImageView.image = image
			shadowLineAddressImageView.tintColor = UIColor.PurpleColor
		}
		
		if navigationController?.modalPresentationStyle == UIModalPresentationStyle.Popover {
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
			let attributedText = NSMutableAttributedString(string: collectionSite.address.street, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])
			attributedText.appendAttributedString(NSAttributedString(string: "\n\(collectionSite.address.zip)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			attributedText.appendAttributedString(NSAttributedString(string: " \(collectionSite.address.city)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			if !collectionSite.contact.isEmpty {
				attributedText.appendAttributedString(NSAttributedString(string: "\n\nKontakt: \(collectionSite.contact)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			}
			if !collectionSite.webAddress.isEmpty {
				attributedText.appendAttributedString(NSAttributedString(string: "\nWebseite: \(collectionSite.webAddress)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			}
			if !collectionSite.openingHint.isEmpty {
				attributedText.appendAttributedString(NSAttributedString(string: "\nWeitere Angaben: \(collectionSite.openingHint)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
			}
			addressTextView.attributedText = attributedText
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		setupTextViews()
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition(nil) { (context) -> Void in
			self.setupTextViews()
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
	
	private func setupTextViews() {
		itemsTextView.scrollRangeToVisible(NSMakeRange(0, 0))
		addressTextView.scrollRangeToVisible(NSMakeRange(0, 0))
	}
}
//
//  MoreViewController.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 20.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {
	//Icons made by [robin kylander] from www.flaticon.com

	@IBOutlet weak var heartContainerView: UIView!
	@IBOutlet weak var textView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		textView.delegate = self
		textView.contentInset = UIEdgeInsets(top: heartContainerView.bounds.size.height, left: 0, bottom: 0, right: 0)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadMoreData()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	//, NSForegroundColorAttributeName : UIColor.colorWithWebColor("#a0388c", alpha: 1.0)!
	private func loadMoreData() {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = NSTextAlignment.center

		let attributedText = NSMutableAttributedString(string: "helphelp²",
		                                               attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17),
		                                                            NSAttributedStringKey.link : NSURL(string: "https://helphelp2.com")!])

		attributedText.append(NSAttributedString(string: "\n\nImpressum: Rüdiger Trost / Lev Stipakov", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
		attributedText.append(NSAttributedString(string: "\nHofmannstraße 30", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
		attributedText.append(NSAttributedString(string: "\n81379 München", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
		attributedText.append(NSAttributedString(string: "\ninfo@helphelp2.com", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))

		attributedText.append(NSAttributedString(string: "\n\nUm Adressen hinzuzufügen gehe zu: ", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
		attributedText.append(NSAttributedString(string: "\nhttps://helphelp2.com/admin", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))

		attributedText.append(NSAttributedString(string: "\n\niOS Version entwickelt von Joachim Deelen", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11)]))
		attributedText.append(NSAttributedString(string: "\nfür micabo-software UG",
		                                         attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11),
		                                                      NSAttributedStringKey.link : NSURL(string: "http://www.micabo.de")!]))
		attributedText.append(NSAttributedString(string: " (haftungsbeschränkt)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11)]))
		attributedText.append(NSAttributedString(string: "\n\n\nIcons made by ", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
		attributedText.append(NSAttributedString(string: "robin kylander",
		                                         attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10),
		                                                      NSAttributedStringKey.link : NSURL(string: "http://www.flaticon.com/authors/robin-kylander")!]))
		attributedText.append(NSAttributedString(string: " from ", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
		attributedText.append(NSAttributedString(string: "www.flaticon.com",
		                                         attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10),
		                                                      NSAttributedStringKey.link : NSURL(string: "http://www.flaticon.com")!]))
		self.textView.attributedText = attributedText
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension MoreViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
		return true
	}
}

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
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		loadMoreData()
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	//, NSForegroundColorAttributeName : UIColor.colorWithWebColor("#a0388c", alpha: 1.0)!
	private func loadMoreData() {
		let centerParagraphStyle = NSMutableParagraphStyle()
		centerParagraphStyle.alignment = NSTextAlignment.Center
		
		let attributedText = NSMutableAttributedString(string: "helphelp²", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(17), NSLinkAttributeName : NSURL(string: "https://helphelp2.com")!])
			
		attributedText.appendAttributedString(NSAttributedString(string: "\n\niOS Version entwickelt von Joachim Deelen", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\nfür micabo-software UG (haftungsbeschränkt)", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\n\nUm Adressen hinzuzufügen gehe zu: ", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\nhttps://helphelp2.com/admin", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\n\nImpressum: Rüdiger Trost / Lev Stipakov", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\nHofmannstraße 30", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\n81379 München", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		attributedText.appendAttributedString(NSAttributedString(string: "\ninfo@helphelp2.com", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)]))
		self.textView.attributedText = attributedText
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension MoreViewController: UITextViewDelegate {
	func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
		return true
	}
}
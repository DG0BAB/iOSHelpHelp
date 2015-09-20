//
//  UIIColor+HelpHelp.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 17.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//
import Foundation
import UIKit.UIColor

extension UIColor {
	static var GreenColor: UIColor {
		return UIColor(red: 30/255, green: 147/255, blue: 167/255, alpha: 1.0)
	}
	
	static var PurpleColor: UIColor {
		return UIColor(red: 141/255, green: 67/255, blue: 139/255, alpha: 1.0)
	}

	class func colorWithWebColor(webColorString:String, alpha:CGFloat) -> UIColor? {
		
		guard webColorString.hasPrefix("#") && webColorString.characters.count == 7 else { return nil }
		
		let stringArray = Array(webColorString.characters)
		let red = String(stringArray[1...2])
		let green = String(stringArray[3...4])
		let blue = String(stringArray[5...6])
		var redValue:UInt32 = 0; var greenValue:UInt32 = 0;	var blueValue:UInt32 = 0
		NSScanner(string: red).scanHexInt(&redValue); NSScanner(string: green).scanHexInt(&greenValue); NSScanner(string: blue).scanHexInt(&blueValue)
		return UIColor(red: CGFloat(Double(redValue)/255), green: CGFloat(Double(greenValue)/255), blue: CGFloat(Double(blueValue)/255), alpha: 1.0)
	}
}

extension Array where Element: Equatable {
	mutating func removeObject(object : Array.Generator.Element) {
		while let index = self.indexOf(object){
			self.removeAtIndex(index)
		}
	}
}
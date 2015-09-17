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
}

extension Array where Element: Equatable {
	mutating func removeObject(object : Array.Generator.Element) {
		while let index = self.indexOf(object){
			self.removeAtIndex(index)
		}
	}
}
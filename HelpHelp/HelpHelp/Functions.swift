//
//  Functions.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 28.11.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

// MARK: - Localize


public func LocalizedString(key: String, args: String...) -> String {
	let str = NSLocalizedString(key, comment: "")
	return replacePlaceholders(str, args: args)
	
}

public func LocalizedUppercaseString(string:String, args: String...) -> String {
	let str = LocalizedString(string).uppercaseStringWithLocale(NSLocale.currentLocale())
	return replacePlaceholders(str, args: args)
}

public func replacePlaceholders(placeholderString: String, args: [String]) -> String {
	var str = placeholderString
	var finalStr = str
	let openingToken:Character = "<"
	let closingToken:Character = ">"
	for arg in args {
		guard let openingIndex = str.indexOfCharacter(openingToken),
			closingIndex = str.indexOfCharacter(closingToken)
		else { return placeholderString }
		
		let range = str.startIndex.advancedBy(openingIndex)...str.startIndex.advancedBy(closingIndex)
		let replacedString = str.substringWithRange(range)
		finalStr = finalStr.stringByReplacingOccurrencesOfString(replacedString, withString: arg, options: [], range: nil)
		str = str.stringByReplacingCharactersInRange(str.startIndex...str.startIndex.advancedBy(openingIndex), withString: "")
	}
	return finalStr
}

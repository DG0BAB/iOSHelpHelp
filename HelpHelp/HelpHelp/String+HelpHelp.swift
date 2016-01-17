//
//  String+HelpHelp.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 28.11.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

public extension String {
	
	/// Returns the index of the first occurence of "char"
	/// - parameter char: Character to get the index of
	/// - returns: Index of the first occurence of char (optional)
	public func indexOfCharacter(char: Character) -> Int? {
		if let idx = self.characters.indexOf(char) {
			return self.startIndex.distanceTo(idx)
		}
		return nil
	}
}

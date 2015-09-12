//
//  Communicator.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation


class Communicator {
	typealias SuccessType = (resultData:NSData) -> Void
	typealias FailureType = (error:CommunicatorError) -> Void
	
	let URL:NSURL!
	
	required init(URL:NSURL) {
		self.URL = URL
	}
	
	convenience init?(url:String) {
		if let URL:NSURL = NSURL(string: url) {
			self.init(URL: URL)
		} else {
			return nil
		}
	}
}

public enum CommunicatorError : ErrorType {
	case Client(NSError?)
	case Server(NSError?)
}
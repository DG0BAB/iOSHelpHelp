//
//  Communicator.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation


class Communicator: NSObject {
	typealias SuccessType = (_ resultData: Data) -> Void
	typealias FailureType = (_ error: CommunicatorError) -> Void

	let url: URL!

	required init(url: URL) {
		self.url = url
	}

	convenience init?(urlString: String) {
		guard let url: URL = URL(string: urlString) else { return nil }
		self.init(url: url)
	}
}

public enum CommunicatorError: Error {
	case client(Error?)
	case server(Error?)
}

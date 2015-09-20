//
//  HTTPCommunicator.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

enum HTTPCommunicatorError: ErrorType {
	case MissingPath
}

class HTTPCommunicator: Communicator {
	
	var session:NSURLSession?
	var task:NSURLSessionTask?
	
	func GET(path:String, success:Communicator.SuccessType, failure:Communicator.FailureType) throws -> Void {
		
		guard !path.isEmpty else { throw HTTPCommunicatorError.MissingPath }
		
		let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
		sessionConfiguration.timeoutIntervalForRequest = 2
		
		session = NSURLSession(configuration: sessionConfiguration)
		if  let requestURL = NSURL(string: path, relativeToURL: URL) {
			task = session!.dataTaskWithURL(requestURL) { [weak self] data, response, error in
				self?.session?.invalidateAndCancel()
				if let response = response as? NSHTTPURLResponse {
					
					switch response.statusCode {
						
					case HTTPStatusCode.OK_200.rawValue:
						if let data = data {
							success(resultData:data)
						}
						
					case HTTPStatusCode.ClientError.startValue...HTTPStatusCode.ClientError.endValue:
						print("Client-Error")
						failure(error: CommunicatorError.Client(error))
						
					case HTTPStatusCode.ServerError.startValue...HTTPStatusCode.ServerError.endValue:
						print("Server-Error")
						failure(error: CommunicatorError.Server(error))
						
					default: break
						
					}
				}
			}
			task!.resume()
		}
	}
}


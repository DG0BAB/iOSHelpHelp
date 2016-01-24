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
	
	private var sessionConfiguration: NSURLSessionConfiguration {
		get {
			let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
			configuration.timeoutIntervalForRequest = 2
			return configuration
		}
	}
	
	private var session: NSURLSession {
		get {
			return NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
		}
	}
	private var data: NSMutableData?
	private var onSuccess: Communicator.SuccessType?
	private var onFailure: Communicator.FailureType?
	
	func GET(path:String, success: Communicator.SuccessType, failure: Communicator.FailureType) throws -> Void {
		
		guard !path.isEmpty else { throw HTTPCommunicatorError.MissingPath }
		
		if let requestURL = NSURL(string: path, relativeToURL: URL) {
			onSuccess = success
			onFailure = failure
			session.dataTaskWithURL(requestURL).resume()
		}
	}
}

extension HTTPCommunicator : NSURLSessionDataDelegate {
	
	func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
		if let response = response as? NSHTTPURLResponse {
			switch response.statusCode {
				
			case HTTPStatusCode.OK_200.rawValue:
				data = NSMutableData()
				completionHandler(.Allow)
				
			case HTTPStatusCode.ClientError.startValue...HTTPStatusCode.ClientError.endValue:
				print("Client-Error")
				onFailure?(error: .Client(nil))
				completionHandler(.Cancel)
				
			case HTTPStatusCode.ServerError.startValue...HTTPStatusCode.ServerError.endValue:
				print("Server-Error")
				onFailure?(error: .Server(nil))
				completionHandler(.Cancel)
				
			default: break
				
			}
		}
	}

	func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
		print("Data received: \(data)\n\n")
		self.data?.appendData(data)
	}
	
	func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
		if let error = error {
			onFailure?(error: .Client(error))
		} else if let data = self.data {
			onSuccess?(resultData: data)
		}
	}
}


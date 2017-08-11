//
//  HTTPCommunicator.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 12.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

enum HTTPCommunicatorError: Error {
	case missingPath
}

class HTTPCommunicator: Communicator {

	private var sessionConfiguration: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 2
		return configuration
	}

	private var session: URLSession {
		return URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
	}
	fileprivate var data: Data?
	fileprivate var onSuccess: Communicator.SuccessType?
	fileprivate var onFailure: Communicator.FailureType?

	func GET(path: String, success: @escaping Communicator.SuccessType, failure: @escaping Communicator.FailureType) throws {

		guard !path.isEmpty else { throw HTTPCommunicatorError.missingPath }

		if let requestURL = URL(string: path, relativeTo: url) {
			onSuccess = success
			onFailure = failure
			session.dataTask(with: requestURL).resume()
		}
	}
}

extension HTTPCommunicator : URLSessionDataDelegate {

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {

		if let response = response as? HTTPURLResponse {
			switch response.statusCode {

			case HTTPStatusCode.ok_200.rawValue:
				data = Data()
				completionHandler(.allow)

			case HTTPStatusCode.clientError.startValue...HTTPStatusCode.clientError.endValue:
				print("Client-Error")
				onFailure?(.client(nil))
				completionHandler(.cancel)

			case HTTPStatusCode.serverError.startValue...HTTPStatusCode.serverError.endValue:
				print("Server-Error")
				onFailure?(.server(nil))
				completionHandler(.cancel)

			default: break

			}
		}
	}

	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		print("Data received: \(data)\n\n")
		self.data?.append(data)
	}

	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			onFailure?(.client(error))
		} else if let data = self.data {
			onSuccess?(data)
		}
	}
}

//
//  Int+HelpHelp.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 19.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

extension Int {
	public var second: NSTimeInterval {
		return NSTimeInterval(self)
	}
	
	public var seconds: NSTimeInterval {
		return NSTimeInterval(self)
	}
	
	public var minute: NSTimeInterval {
		return NSTimeInterval(self * 60)
	}
	
	public var minutes: NSTimeInterval {
		return self.minute
	}
	
	public var hour: NSTimeInterval {
		return NSTimeInterval(self * 3600)
	}
	
	public var hours: NSTimeInterval {
		return self.hour
	}
	
	public var day: NSTimeInterval {
		return NSTimeInterval(self * 86400)
	}
	
	public var days: NSTimeInterval {
		return self.day
	}
	
	public var week: NSTimeInterval {
		return NSTimeInterval(self * 86400 * 7)
	}
	
	public var weeks: NSTimeInterval {
		return self.week
	}
}
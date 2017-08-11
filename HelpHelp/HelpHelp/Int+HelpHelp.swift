//
//  Int+HelpHelp.swift
//  HelpHelp
//
//  Created by Joachim Deelen on 19.09.15.
//  Copyright © 2015 micabo-software UG. All rights reserved.
//

import Foundation

extension Int {
	public var second: TimeInterval {
		return TimeInterval(self)
	}

	public var seconds: TimeInterval {
		return TimeInterval(self)
	}

	public var minute: TimeInterval {
		return TimeInterval(self * 60)
	}

	public var minutes: TimeInterval {
		return self.minute
	}

	public var hour: TimeInterval {
		return TimeInterval(self * 3600)
	}

	public var hours: TimeInterval {
		return self.hour
	}

	public var day: TimeInterval {
		return TimeInterval(self * 86400)
	}

	public var days: TimeInterval {
		return self.day
	}

	public var week: TimeInterval {
		return TimeInterval(self * 86400 * 7)
	}

	public var weeks: TimeInterval {
		return self.week
	}
}

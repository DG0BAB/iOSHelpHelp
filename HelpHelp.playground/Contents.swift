//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

let webColor = "#0092a8"

let skip = NSCharacterSet(charactersInString: "#")

if webColor.hasPrefix("#") && webColor.characters.count == 7 {
	let stringArray = Array(webColor.characters)
	let red = String(stringArray[1...2])
	let green = String(stringArray[3...4])
	let blue = String(stringArray[5...6])
	var redValue:UInt32 = 0
	var greenValue:UInt32 = 0
	var blueValue:UInt32 = 0
	NSScanner(string: red).scanHexInt(&redValue)
	print(redValue)
	NSScanner(string: green).scanHexInt(&greenValue)
	print(greenValue)
	NSScanner(string: blue).scanHexInt(&blueValue)
	print(blueValue)
	
	let value = Double(greenValue)/255
	
	let color = UIColor(red: CGFloat(Double(redValue)/255), green: CGFloat(Double(greenValue)/255), blue: CGFloat(Double(blueValue)/255), alpha: 1.0)
}


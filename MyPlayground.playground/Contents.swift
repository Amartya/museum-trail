//: Playground - noun: a place where people can play

import UIKit
import Foundation

var str = "Hello, playground"

var cal = NSCalendar.currentCalendar()
var date = NSDate()
var components = cal.components([NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.TimeZone, NSCalendarUnit.WeekOfMonth], fromDate: date)
components.day
components.timeZone
components.weekOfMonth
NSCalendar.componentsInTimeZone(cal)


var f = "2016-2-22-Participant100-Audio.m4a"





//: Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground

let myview = UIView(frame: CGRect(x:0.0,y:0.0,width:640,height:1136))
//let bgColor = UIColor(red: 0.7, green: 0.3, blue: 0.2, alpha: 0.5)

myview.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.9);


let myclass = WalkAndRun(view: myview);


XCPlaygroundPage.currentPage.liveView = myview



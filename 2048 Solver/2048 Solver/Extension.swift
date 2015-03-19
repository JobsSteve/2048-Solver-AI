//
//  Extension.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/17/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import UIKit

var screenWidth: CGFloat { return UIScreen.mainScreen().bounds.size.width }
var screenHeight: CGFloat { return UIScreen.mainScreen().bounds.size.height }

var screenSize: CGSize { return UIScreen.mainScreen().bounds.size }
var screenBounds: CGRect { return UIScreen.mainScreen().bounds }

var isIpad: Bool { return UIDevice.currentDevice().userInterfaceIdiom == .Pad }

var is3_5InchScreen: Bool { return screenHeight ~= 480.0 }
var is4InchScreen: Bool { return screenHeight ~= 568.0 }
var isIphone6: Bool { return screenHeight ~= 667.0 }
var isIphone6Plus: Bool { return screenHeight ~= 736.0 }


func printOutCommand(command: MoveCommand) {
    switch command.direction {
    case .Up:
        logDebug("Up")
    case .Down:
        logDebug("Down")
    case .Left:
        logDebug("Left")
    case .Right:
        logDebug("Right")
    }
}

func printOutMoveActions(actions: [MoveAction]) {
    for action in actions {
        println("From: \(action.fromCoordinates) To:\(action.toCoordinate)")
    }
}
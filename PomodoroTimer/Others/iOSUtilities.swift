//
//  iOSUtilities.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/04/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    func toSuperscript() -> String {
        var j = self
        var ret = ""
        if self >= 10 {
            let i = self / 10
            ret = i.toSuperscript()
            j = self % 10
        }
        
        let uni: Int
        if j == 2 {
            uni = 0x00B2
        }
        else if j == 3 {
            uni = 0x00B3
        }
        else if j == 1 {
            uni = 0x00B9
        }
        else {
            uni = 0x2070 + j
        }
        let scalarValue = UnicodeScalar(uni)!
        let string = String(scalarValue)
        
        return ret + string
    }
}

// Inspired by https://stackoverflow.com/a/48496364
extension UINavigationController {
    func pushViewControllerFromLeft(controller: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.45
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .default)
        view.window!.layer.add(transition, forKey: kCATransition)
        pushViewController(controller, animated: false)
    }
}

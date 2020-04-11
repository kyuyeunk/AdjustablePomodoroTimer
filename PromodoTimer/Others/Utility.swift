//
//  Utility.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/04/07.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation
import UIKit

// Copied from https://stackoverflow.com/a/35360697
extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

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
#if os(iOS)
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
#endif

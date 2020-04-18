//
//  SharedUtilities.swift
//  PomodoroTimer
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

enum TimerType: Int, Codable {
    case positive
    case negative
}

struct WCSessionRequest {
    static let request = "Request"
    static let togglInfo = "TogglInfo"
    static let timerList = "TimerList"
}

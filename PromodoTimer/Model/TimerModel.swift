//
//  TimerModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TimerModel: Codable {
    var timerName: String
    var startTime: [TimerType: Int] = [:]
    var autoRepeat: Bool
    var accumulatePassedTime: Bool
    var timerAlarm: [TimerType: Int] = [:]
    var alertTimerEnd: Bool
    
    var userDefinedTracking: [TimerType: trackingInfo] = [:]
    init() {
        self.timerName = "Default Timer"
        self.startTime[.positive] = 30
        self.startTime[.negative] = -15
        self.autoRepeat = true
        self.accumulatePassedTime = false
        self.timerAlarm[.positive] = 1005
        self.timerAlarm[.negative] = 1004
        self.alertTimerEnd = true
    }
}

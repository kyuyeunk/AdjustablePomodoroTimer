//
//  TimerModel.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TimerModel: Codable, Identifiable {
    var maxMinutes: Int
    var timerName: String
    var startTime: [TimerType: Int] = [:]
    var autoRepeat: Bool
    var accumulatePassedTime: Bool
    var timerAlarmID: [TimerType: Int] = [:]
    var alertTimerEnd: Bool
    var repeatAlarmOption: Bool
    var repeatAlarm: Bool {
        return alertTimerEnd && repeatAlarmOption
    }
    
    var userDefinedTracking: [TimerType: trackingInfo] = [:]
    
    init() {
        self.timerName = "Default Timer"
        self.startTime[.positive] = 480
        self.startTime[.negative] = -360
        self.autoRepeat = true
        self.accumulatePassedTime = false
        self.timerAlarmID[.positive] = 5
        self.timerAlarmID[.negative] = 4
        self.alertTimerEnd = false
        self.repeatAlarmOption = false
        self.maxMinutes = 12
    }
    
    init(timerModel: TimerModel) {
        self.timerName = timerModel.timerName
        self.startTime[.positive] = timerModel.startTime[.positive]
        self.startTime[.negative] = timerModel.startTime[.negative]
        self.autoRepeat = timerModel.autoRepeat
        self.accumulatePassedTime = timerModel.accumulatePassedTime
        self.timerAlarmID[.positive] = timerModel.timerAlarmID[.positive]
        self.timerAlarmID[.negative] = timerModel.timerAlarmID[.negative]
        self.alertTimerEnd = timerModel.alertTimerEnd
        self.repeatAlarmOption = timerModel.repeatAlarmOption
        self.maxMinutes = timerModel.maxMinutes
        self.userDefinedTracking = timerModel.userDefinedTracking
    }
}

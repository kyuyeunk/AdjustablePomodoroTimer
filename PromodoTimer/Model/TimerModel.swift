//
//  TimerModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TimerModel: Codable {
    var maxMinutes: Int
    var timerName: String
    var startTime: [TimerType: Int] = [:]
    var autoRepeat: Bool
    var accumulatePassedTime: Bool
    var timerAlarm: [TimerType: Int] = [:]
    var alertTimerEnd: Bool
    var repeatAlarmOption: Bool
    var repeatAlarm: Bool {
        return alertTimerEnd && repeatAlarmOption
    }
    
    //TODO: add ability to check if userDefinedTracking's info corresponds
    //With current toggl credential
    var userDefinedTracking: [TimerType: trackingInfo] = [:]
    init() {
        self.timerName = "Default Timer"
        self.startTime[.positive] = 0
        self.startTime[.negative] = 0
        self.autoRepeat = false
        self.accumulatePassedTime = false
        self.timerAlarm[.positive] = 1005
        self.timerAlarm[.negative] = 1004
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
        self.timerAlarm[.positive] = timerModel.timerAlarm[.positive]
        self.timerAlarm[.negative] = timerModel.timerAlarm[.negative]
        self.alertTimerEnd = timerModel.alertTimerEnd
        self.repeatAlarmOption = timerModel.repeatAlarmOption
        self.maxMinutes = timerModel.maxMinutes
    }
}

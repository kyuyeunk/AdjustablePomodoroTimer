//
//  TimerModel.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TimerModel: Codable, Identifiable {
    var maxMinutes: Int { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var timerName: String{ didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var startTime: [TimerType: Int] = [:] { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var autoRepeat: Bool { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var accumulatePassedTime: Bool { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var timerAlarmID: [TimerType: Int] = [:] { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var alertTimerEnd: Bool { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var repeatAlarmOption: Bool { didSet { modifiedDate = Date().timeIntervalSince1970 } }
    var repeatAlarm: Bool {
        return alertTimerEnd && repeatAlarmOption
    }
    var createdDate: TimeInterval
    var modifiedDate: TimeInterval
    
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
        self.createdDate = Date().timeIntervalSince1970
        self.modifiedDate = self.createdDate
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
        self.createdDate = timerModel.createdDate
        self.modifiedDate = timerModel.modifiedDate
    }
    
    enum timerModelComparison {
        case same
        case different
        case newer
        case older
    }
    
    func compare(timerModel: TimerModel) -> timerModelComparison {
        if self.createdDate == timerModel.createdDate {
            if self.modifiedDate == timerModel.modifiedDate {
                return .same
            }
            else if self.modifiedDate > timerModel.modifiedDate {
                return .older
            }
            else {
                return .newer
            }
        }
        else {
            return .different
        }
    }
}

//
//  watchOSUtilities.swift
//  PomodoroTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/14.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

enum pageNames: Int {
    case timerListTableView
    case timerView
    case timerSettingsView
    case settingsView
}

let resetTimerSettingsViewNotificationName = Notification.Name("resetTimerSettings")
let changePageNotificationName = Notification.Name("changePage")

struct contextWrapper {
    var timerModel: TimerModel
    var timerType: TimerType
}

//
//  Constants.swift
//  PromodoTimer for Watch Extension
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

let changePageNotificationName = Notification.Name("changePage")

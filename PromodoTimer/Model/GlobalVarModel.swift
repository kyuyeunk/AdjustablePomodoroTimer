//
//  GlobalVarModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/14.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

struct GlobalVar {
    static var timeController = TimeController()
    static var settings = Settings()
    static var toggl = TogglController()
    static var timerList: [TimerModel] = []
}

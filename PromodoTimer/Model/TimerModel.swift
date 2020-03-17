//
//  TimerModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TimerModel {
    var timerName: String
    var posStartTime: Int
    var negStartTime: Int
    var autoRepeat: Bool
    
    var userDefinedTracking: [TrackingType: trackingInfo] = [:]
    init() {
        self.timerName = "Default Timer"
        self.posStartTime = 30
        self.negStartTime = -15
        self.autoRepeat = true
        
        userDefinedTracking[.positive] = trackingInfo(project: GlobalVar.settings.projects[0], desc: "Pos Test")
        userDefinedTracking[.negative] = trackingInfo(project: GlobalVar.settings.projects[1], desc: "Neg Test")
    }
}

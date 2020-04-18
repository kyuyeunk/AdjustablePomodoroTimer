//
//  TimerInfoCell.swift
//  PomodoroTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TimerInfoViewCell: NSObject {
    @IBOutlet weak var timerName: WKInterfaceLabel!
    @IBOutlet weak var posTime: WKInterfaceLabel!
    @IBOutlet weak var negTime: WKInterfaceLabel!
    @IBOutlet weak var selectedSeparator: WKInterfaceSeparator!
}

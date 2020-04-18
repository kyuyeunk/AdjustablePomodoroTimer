//
//  SwitchSettingCell.swift
//  PomodoroTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

protocol SwitchSettingDelegate {
    func updateSwitchValue(switchSettingViewCell: SwitchSettingViewCell, value: Bool)
}

class SwitchSettingViewCell: NSObject {
    var switchSettingDelegate: SwitchSettingDelegate?
    @IBOutlet weak var settingValueSwitch: WKInterfaceSwitch!
    @IBAction func switchTapped(_ value: Bool) {
        WKInterfaceDevice.current().play(.click)
        print("Switch set to \(value)")
        if let delegate = switchSettingDelegate {
            delegate.updateSwitchValue(switchSettingViewCell: self, value: value)
        }
    }
}

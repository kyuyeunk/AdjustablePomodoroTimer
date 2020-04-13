//
//  TimerSettingsController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TimerSettingsController: WKInterfaceController {
    @IBOutlet weak var timerSettingsTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
     
    }
    
    func initCells() {
        let currTimer = GlobalVar.settings.currTimer
        
        timerSettingsTable.setRowTypes(["sliderSetting", "sliderSetting", "sliderSetting",
                                        "switchSetting", "switchSetting", "switchSetting"])
        var sliderCell = timerSettingsTable.rowController(at: 0) as! SliderSettingCell
        sliderCell.settingLabel.setText("Max Minutes")
        sliderCell.setMaxValue(value: 60)
        sliderCell.setValue(value: currTimer.maxMinutes)
        
        
        sliderCell = timerSettingsTable.rowController(at: 1) as! SliderSettingCell
        sliderCell.settingLabel.setText("Pos Minutes")
        sliderCell.setMaxValue(value: currTimer.maxMinutes)
        sliderCell.setValue(value: currTimer.startTime[.positive]! / 60)
        
        sliderCell = timerSettingsTable.rowController(at: 2) as! SliderSettingCell
        sliderCell.settingLabel.setText("Neg Minutes")
        sliderCell.setMaxValue(value: currTimer.maxMinutes)
        sliderCell.setValue(value: abs(currTimer.startTime[.negative]! / 60))
        
        var switchCell = timerSettingsTable.rowController(at: 3) as! SwitchSettingCell
        switchCell.settingValueSwitch.setTitle("Auto Repeat")
        switchCell.settingValueSwitch.setOn(currTimer.autoRepeat)
        
        switchCell = timerSettingsTable.rowController(at: 4) as! SwitchSettingCell
        switchCell.settingValueSwitch.setTitle("Pop-Up Alarm")
        switchCell.settingValueSwitch.setOn(currTimer.alertTimerEnd)
        
        switchCell = timerSettingsTable.rowController(at: 5) as! SwitchSettingCell
        switchCell.settingValueSwitch.setTitle("Repeat Alarm")
        switchCell.settingValueSwitch.setOn(currTimer.repeatAlarmOption)
        switchCell.settingValueSwitch.setEnabled(currTimer.alertTimerEnd)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

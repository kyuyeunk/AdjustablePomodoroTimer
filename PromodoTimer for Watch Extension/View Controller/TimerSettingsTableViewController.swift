//
//  TimerSettingsController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TimerSettingsTableViewController: WKInterfaceController {
    @IBOutlet weak var timerSettingsTable: WKInterfaceTable!
    
    var workingTimer = TimerModel()
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        timerSettingsTable.setRowTypes(["sliderSetting", "sliderSetting", "sliderSetting",
                                     "switchSetting", "switchSetting", "switchSetting"])
    }
    
    var maxSliderCell: SliderSettingViewCell!
    var posSliderCell: SliderSettingViewCell!
    var negSliderCell: SliderSettingViewCell!
    
    func initCells() {
        workingTimer = TimerModel(timerModel: GlobalVar.settings.currTimer)
        

        maxSliderCell = timerSettingsTable.rowController(at: 0) as? SliderSettingViewCell
        maxSliderCell.settingLabel.setText("Max Minutes")
        maxSliderCell.setMaxValue(value: 60)
        maxSliderCell.setValue(value: workingTimer.maxMinutes)
        maxSliderCell.sliderUpdateDelegate = self
        
        posSliderCell = timerSettingsTable.rowController(at: 1) as? SliderSettingViewCell
        posSliderCell.settingLabel.setText("Pos Minutes")
        posSliderCell.setMaxValue(value: workingTimer.maxMinutes)
        posSliderCell.setValue(value: workingTimer.startTime[.positive]! / 60)
        posSliderCell.sliderUpdateDelegate = self
        
        negSliderCell = timerSettingsTable.rowController(at: 2) as? SliderSettingViewCell
        negSliderCell.settingLabel.setText("Neg Minutes")
        negSliderCell.setMaxValue(value: workingTimer.maxMinutes)
        negSliderCell.setValue(value: abs(workingTimer.startTime[.negative]! / 60))
        negSliderCell.sliderUpdateDelegate = self
        
        var switchCell = timerSettingsTable.rowController(at: 3) as! SwitchSettingViewCell
        switchCell.settingValueSwitch.setTitle("Auto Repeat")
        switchCell.settingValueSwitch.setOn(workingTimer.autoRepeat)
        
        switchCell = timerSettingsTable.rowController(at: 4) as! SwitchSettingViewCell
        switchCell.settingValueSwitch.setTitle("Pop-Up Alarm")
        switchCell.settingValueSwitch.setOn(workingTimer.alertTimerEnd)
        
        switchCell = timerSettingsTable.rowController(at: 5) as! SwitchSettingViewCell
        switchCell.settingValueSwitch.setTitle("Repeat Alarm")
        switchCell.settingValueSwitch.setOn(workingTimer.repeatAlarmOption)
        switchCell.settingValueSwitch.setEnabled(workingTimer.alertTimerEnd)
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

extension TimerSettingsTableViewController: SliderUpdateDelegate {
    func updateMaxValue(sliderSettingViewCell: SliderSettingViewCell, value: Int) {
        switch(sliderSettingViewCell) {
        case maxSliderCell:
            print("[Timer Setting] Max cell slider tapped")
            workingTimer.maxMinutes = value
            
            var sliderCell = timerSettingsTable.rowController(at: 1) as! SliderSettingViewCell
            if workingTimer.startTime[.positive]! / 60 > workingTimer.maxMinutes {
                workingTimer.startTime[.positive] = value * 60
            }
            sliderCell.setMaxValue(value: value)
            sliderCell.setValue(value: workingTimer.startTime[.positive]! / 60)
            
            sliderCell = timerSettingsTable.rowController(at: 2) as! SliderSettingViewCell
            if abs(workingTimer.startTime[.negative]!) / 60 > workingTimer.maxMinutes {
                workingTimer.startTime[.negative] = -value * 60
                sliderCell.setValue(value: value)
            }
            sliderCell.setMaxValue(value: value)
            sliderCell.setValue(value: abs(workingTimer.startTime[.negative]!) / 60)
        case posSliderCell:
            print("[Timer Setting] Pos cell slider tapped")
            workingTimer.startTime[.positive] = value * 60
        case negSliderCell:
            print("[Timer Setting] Neg cell slider tapped")
            workingTimer.startTime[.negative] = -value * 60
        default:
            print("[Timer Setting] ???")
        }
        
    }
}

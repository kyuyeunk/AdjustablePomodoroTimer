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
        timerSettingsTable.setRowTypes(["sliderSetting", "sliderSetting", "sliderSetting",
                                        "switchSetting", "switchSetting", "switchSetting"])
        var sliderCell = timerSettingsTable.rowController(at: 0) as! SliderSettingCell
        sliderCell.settingLabel.setText("Max Minutes")
        sliderCell.setValue(value: 20)
        sliderCell.settingValueSlider.setNumberOfSteps(10)
        
        sliderCell = timerSettingsTable.rowController(at: 1) as! SliderSettingCell
        sliderCell.settingLabel.setText("Pos Minutes")
        sliderCell.setValue(value: 20)
        sliderCell.settingValueSlider.setNumberOfSteps(10)
        
        sliderCell = timerSettingsTable.rowController(at: 2) as! SliderSettingCell
        sliderCell.settingLabel.setText("Neg Minutes")
        sliderCell.setValue(value: 20)
        sliderCell.settingValueSlider.setNumberOfSteps(10)
        
        var switchCell = timerSettingsTable.rowController(at: 3) as! SwitchSettingCell
        switchCell.settingValueSwitch.setTitle("Auto Start")
        switchCell.settingValueSwitch.setOn(true)
        
        switchCell = timerSettingsTable.rowController(at: 4) as! SwitchSettingCell
        switchCell.settingValueSwitch.setTitle("Pop-Up")
        switchCell.settingValueSwitch.setOn(false)
        
        switchCell = timerSettingsTable.rowController(at: 5) as! SwitchSettingCell
        switchCell.settingValueSwitch.setTitle("Repeat Alarm")
        switchCell.settingValueSwitch.setOn(false)
        switchCell.settingValueSwitch.setEnabled(false)
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

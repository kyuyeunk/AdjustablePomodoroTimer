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
        
        timerSettingsTable.setNumberOfRows(3, withRowType: "timerSetting")
        
        initCells()
    }
    
    func initCells() {
        var cell = timerSettingsTable.rowController(at: 0) as! TimerSettingCell
        cell.settingLabel.setText("Max Minutes")
        cell.setValue(value: 20)
        cell.settingValueSlider.setNumberOfSteps(10)
        
        cell = timerSettingsTable.rowController(at: 1) as! TimerSettingCell
        cell.settingLabel.setText("Pos Minutes")
        cell.setValue(value: 20)
        cell.settingValueSlider.setNumberOfSteps(10)
        
        cell = timerSettingsTable.rowController(at: 2) as! TimerSettingCell
        cell.settingLabel.setText("Neg Minutes")
        cell.setValue(value: 20)
        cell.settingValueSlider.setNumberOfSteps(10)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

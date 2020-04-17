//
//  SettingsViewController.swift
//  
//
//  Created by Kyu Yeun Kim on 2020/04/14.
//

import WatchKit
import WatchConnectivity

class SettingsViewController: WKInterfaceController {
    @IBOutlet weak var settingsTable: WKInterfaceTable!
    
    var tickingSoundSwitchCell: SwitchSettingViewCell!
    var syncButtonCell: ButtonViewCell!
    
    override func awake(withContext context: Any?) {
         super.awake(withContext: context)
     }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    func initCells() {
        settingsTable.setRowTypes([ "switchSetting", "button"])
        
        tickingSoundSwitchCell = settingsTable.rowController(at: 0) as? SwitchSettingViewCell
        tickingSoundSwitchCell.settingValueSwitch.setTitle("Ticking Sound")
        tickingSoundSwitchCell.settingValueSwitch.setOn(GlobalVar.settings.tickingSound)
        tickingSoundSwitchCell.switchSettingDelegate = self
        
        syncButtonCell = settingsTable.rowController(at: 1) as? ButtonViewCell
        syncButtonCell.button.setTitle("Sync Timers")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension SettingsViewController: SwitchSettingDelegate {
    func updateSwitchValue(switchSettingViewCell: SwitchSettingViewCell, value: Bool) {
        if switchSettingViewCell == tickingSoundSwitchCell {
            print("Make ticking sound \(value)")
            GlobalVar.settings.tickingSound = value
        }
    }
}

extension SettingsViewController: ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell) {
        GlobalVar.settings.sendData()
    }
}

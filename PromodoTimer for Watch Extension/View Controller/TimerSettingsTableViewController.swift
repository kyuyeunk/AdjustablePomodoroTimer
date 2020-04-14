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
    
    var timerNameViewCell: TimerNameViewCell!
    
    var saveButtonCell: ButtonViewCell!
    var deleteButtonCell: ButtonViewCell!
    
    var maxSliderCell: SliderSettingViewCell!
    var posSliderCell: SliderSettingViewCell!
    var negSliderCell: SliderSettingViewCell!
    
    
    var autoRepeatSwitchCell: SwitchSettingViewCell!
    var popupSwitchCell: SwitchSettingViewCell!
    var repeatAlarmSwitchCell: SwitchSettingViewCell!
    
    var workingTimer = TimerModel()
    var newTimer = false
    
    override init() {
        super.init()
        createObserver()
        workingTimer = TimerModel(timerModel: GlobalVar.settings.currTimer)
    }
    
    func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetWorkingTimer(_:)),
                                               name: resetTimerSettingsViewNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeToCurrentPage),
                                               name: changePageNotificationName, object: pageNames.timerSettingsView.rawValue)
    }
    
    @objc func changeToCurrentPage() {
        print("Will change to timer settings view")
        super.becomeCurrentPage()
    }
    
    @objc func resetWorkingTimer(_ notification: NSNotification) {
        if let _ = notification.userInfo?["isNewTimer"] as? Bool{
            print("Set New Timer")
            workingTimer = TimerModel()
            newTimer = true
        }
        else {
            print("Set existing timer")
            workingTimer = TimerModel(timerModel: GlobalVar.settings.currTimer)
            newTimer = false
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    func initCells() {
        timerSettingsTable.setRowTypes(["button", "textField", "sliderSetting", "sliderSetting", "sliderSetting",
                                     "switchSetting", "switchSetting", "switchSetting", "button"])

        saveButtonCell = timerSettingsTable.rowController(at: 0) as? ButtonViewCell
        saveButtonCell.button.setTitle("Save Timer")
        saveButtonCell.buttonDelegate = self
        
        timerNameViewCell = timerSettingsTable.rowController(at: 1) as? TimerNameViewCell
        timerNameViewCell.textField.setText(workingTimer.timerName)
        timerNameViewCell.textFieldDelegate = self
        
        maxSliderCell = timerSettingsTable.rowController(at: 2) as? SliderSettingViewCell
        maxSliderCell.settingLabel.setText("Max Minutes")
        maxSliderCell.setMaxValue(value: 60)
        maxSliderCell.setValue(value: workingTimer.maxMinutes)
        maxSliderCell.sliderUpdateDelegate = self
        
        posSliderCell = timerSettingsTable.rowController(at: 3) as? SliderSettingViewCell
        posSliderCell.settingLabel.setText("Pos Minutes")
        posSliderCell.setMaxValue(value: workingTimer.maxMinutes)
        posSliderCell.setValue(value: workingTimer.startTime[.positive]! / 60)
        posSliderCell.sliderUpdateDelegate = self
        
        negSliderCell = timerSettingsTable.rowController(at: 4) as? SliderSettingViewCell
        negSliderCell.settingLabel.setText("Neg Minutes")
        negSliderCell.setMaxValue(value: workingTimer.maxMinutes)
        negSliderCell.setValue(value: abs(workingTimer.startTime[.negative]! / 60))
        negSliderCell.sliderUpdateDelegate = self
        
        autoRepeatSwitchCell = timerSettingsTable.rowController(at: 5) as? SwitchSettingViewCell
        autoRepeatSwitchCell.settingValueSwitch.setTitle("Auto Repeat")
        autoRepeatSwitchCell.settingValueSwitch.setOn(workingTimer.autoRepeat)
        autoRepeatSwitchCell.switchSettingDelegate = self
        
        popupSwitchCell = timerSettingsTable.rowController(at: 6) as? SwitchSettingViewCell
        popupSwitchCell.settingValueSwitch.setTitle("Pop-Up Alarm")
        popupSwitchCell.settingValueSwitch.setOn(workingTimer.alertTimerEnd)
        popupSwitchCell.switchSettingDelegate = self
        
        repeatAlarmSwitchCell = timerSettingsTable.rowController(at: 7) as? SwitchSettingViewCell
        repeatAlarmSwitchCell.settingValueSwitch.setTitle("Repeat Alarm")
        repeatAlarmSwitchCell.settingValueSwitch.setOn(workingTimer.repeatAlarmOption)
        repeatAlarmSwitchCell.settingValueSwitch.setEnabled(workingTimer.alertTimerEnd)
        repeatAlarmSwitchCell.switchSettingDelegate = self
        
        deleteButtonCell = timerSettingsTable.rowController(at: 8) as? ButtonViewCell
        deleteButtonCell.button.setTitle("Delete")
        deleteButtonCell.button.setBackgroundColor(.red)
        deleteButtonCell.buttonDelegate = self
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

extension TimerSettingsTableViewController: SliderSettingDelegate {
    func updateSliderValue(sliderSettingViewCell: SliderSettingViewCell, value: Int) {
        switch(sliderSettingViewCell) {
        case maxSliderCell:
            print("[Timer Setting] Max cell slider tapped")
            workingTimer.maxMinutes = value
            
            
            if workingTimer.startTime[.positive]! / 60 > workingTimer.maxMinutes {
                workingTimer.startTime[.positive] = value * 60
            }
            posSliderCell.setMaxValue(value: value)
            posSliderCell.setValue(value: workingTimer.startTime[.positive]! / 60)
            
            if abs(workingTimer.startTime[.negative]!) / 60 > workingTimer.maxMinutes {
                workingTimer.startTime[.negative] = -value * 60
            }
            negSliderCell.setMaxValue(value: value)
            negSliderCell.setValue(value: abs(workingTimer.startTime[.negative]!) / 60)
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

extension TimerSettingsTableViewController: SwitchSettingDelegate {
    func updateSwitchValue(switchSettingViewCell: SwitchSettingViewCell, value: Bool) {
        switch(switchSettingViewCell) {
        case autoRepeatSwitchCell:
            print("[Timer Setting] Auto repeat tapped")
            workingTimer.autoRepeat = value
        case popupSwitchCell:
            print("[Timer Setting] Pop-up tapped")
            workingTimer.alertTimerEnd = value
            repeatAlarmSwitchCell.settingValueSwitch.setEnabled(value)
        case repeatAlarmSwitchCell:
            print("[Timer Setting] Repeat Alarm tapped")
            workingTimer.repeatAlarmOption = value
        default:
            break
        }
    }
}

extension TimerSettingsTableViewController: ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell) {
        if buttonViewCell == saveButtonCell {
            if newTimer {
                GlobalVar.settings.timerList.append(workingTimer)
                GlobalVar.settings.currTimerID = GlobalVar.settings.timerList.count - 1
            }
            else {
                GlobalVar.settings.timerList[GlobalVar.settings.currTimerID] = workingTimer
            }
            GlobalVar.settings.saveTimerList()
            NotificationCenter.default.post(name: changePageNotificationName, object: pageNames.timerListTableView.rawValue)
        }
        else if buttonViewCell == deleteButtonCell {
            if newTimer {
                workingTimer = TimerModel(timerModel: GlobalVar.settings.currTimer)
                newTimer = false
                NotificationCenter.default.post(name: changePageNotificationName, object: pageNames.timerListTableView.rawValue)
            }
            else if GlobalVar.settings.timerList.count == 1 {
                let action = WKAlertAction(title: "Ok", style: .cancel, handler: {})
                presentAlert(withTitle: "Error", message: "There should be at least one timer", preferredStyle: .alert, actions: [action])
            }
            else {
                GlobalVar.settings.timerList.remove(at:  GlobalVar.settings.currTimerID)
                if GlobalVar.settings.currTimerID != 0 {
                    GlobalVar.settings.currTimerID -= 1
                }
                NotificationCenter.default.post(name: changePageNotificationName, object: pageNames.timerListTableView.rawValue)
            }

            
        }    
    }
}



extension TimerSettingsTableViewController: TextFieldDelegate {
    func TextFieldTapped(value: String) {
        workingTimer.timerName = value
    }
}

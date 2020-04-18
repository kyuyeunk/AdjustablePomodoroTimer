//
//  TimerSettingsController.swift
//  PomodoroTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TimerSettingsTableViewController: WKInterfaceController {
    @IBOutlet weak var timerSettingsTable: WKInterfaceTable!
    
    private var timerNameViewCell: TextFieldViewCell!
    
    private var saveButtonCell: ButtonViewCell!
    private var deleteButtonCell: ButtonViewCell!
    
    private var maxSliderCell: SliderSettingViewCell!
    private var posSliderCell: SliderSettingViewCell!
    private var negSliderCell: SliderSettingViewCell!
    
    
    private var autoRepeatSwitchCell: SwitchSettingViewCell!
    private var popupSwitchCell: SwitchSettingViewCell!
    private var repeatAlarmSwitchCell: SwitchSettingViewCell!

    private var togglPosProjectCell: ButtonWithLabelViewCell!
    private var togglNegProjectCell: ButtonWithLabelViewCell!

    private var workingTimer = TimerModel()
    private var newTimer = false
    
    override init() {
        super.init()
        createObserver()
        workingTimer = TimerModel(timerModel: GlobalVar.settings.currTimer)
    }
    
    private func createObserver() {
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
    
    private func initCells() {
        timerSettingsTable.setRowTypes(["button", "textField", "sliderSetting", "sliderSetting", "sliderSetting", "buttonWithLabel",
                                        "buttonWithLabel", "switchSetting", "switchSetting", "switchSetting", "button"])

        saveButtonCell = timerSettingsTable.rowController(at: 0) as? ButtonViewCell
        saveButtonCell.button.setTitle("Save Timer")
        saveButtonCell.button.setBackgroundColor(.blue)
        saveButtonCell.buttonDelegate = self
        
        timerNameViewCell = timerSettingsTable.rowController(at: 1) as? TextFieldViewCell
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
        
        togglPosProjectCell = timerSettingsTable.rowController(at: 5) as? ButtonWithLabelViewCell
        togglPosProjectCell.label.setText("Pos Toggl Project")
        togglPosProjectCell.buttonDelegate = self
        togglPosProjectCell.button.setEnabled(GlobalVar.settings.togglLoggedIn)
        if GlobalVar.settings.togglLoggedIn {
            togglPosProjectCell.button.setEnabled(true)
            if let togglPosProjectName = workingTimer.userDefinedTracking[TimerType.positive]?.project.name {
                togglPosProjectCell.button.setTitle(togglPosProjectName)
            }
            else {
                togglPosProjectCell.button.setTitle("Input Project")
            }
        }
        else {
            togglPosProjectCell.button.setTitle("Logged Out")
            togglPosProjectCell.button.setEnabled(false)
        }
        
        togglNegProjectCell = timerSettingsTable.rowController(at: 6) as? ButtonWithLabelViewCell
        togglNegProjectCell.label.setText("Neg Toggl Project")
        togglNegProjectCell.buttonDelegate = self
        if GlobalVar.settings.togglLoggedIn {
            togglNegProjectCell.button.setEnabled(true)
            if let togglNegProjectName = workingTimer.userDefinedTracking[TimerType.negative]?.project.name {
                togglNegProjectCell.button.setTitle(togglNegProjectName)
            }
            else {
                togglNegProjectCell.button.setTitle("Input Project")
            }
        }
        else {
            togglNegProjectCell.button.setTitle("Logged Out")
            togglNegProjectCell.button.setEnabled(false)
        }
        
        autoRepeatSwitchCell = timerSettingsTable.rowController(at: 7) as? SwitchSettingViewCell
        autoRepeatSwitchCell.settingValueSwitch.setTitle("Auto Repeat")
        autoRepeatSwitchCell.settingValueSwitch.setOn(workingTimer.autoRepeat)
        autoRepeatSwitchCell.switchSettingDelegate = self
        
        popupSwitchCell = timerSettingsTable.rowController(at: 8) as? SwitchSettingViewCell
        popupSwitchCell.settingValueSwitch.setTitle("Pop-Up Alarm")
        popupSwitchCell.settingValueSwitch.setOn(workingTimer.alertTimerEnd)
        popupSwitchCell.switchSettingDelegate = self
        
        repeatAlarmSwitchCell = timerSettingsTable.rowController(at: 9) as? SwitchSettingViewCell
        repeatAlarmSwitchCell.settingValueSwitch.setTitle("Repeat Alarm")
        repeatAlarmSwitchCell.settingValueSwitch.setOn(workingTimer.repeatAlarmOption)
        repeatAlarmSwitchCell.settingValueSwitch.setEnabled(workingTimer.alertTimerEnd)
        repeatAlarmSwitchCell.switchSettingDelegate = self
        
        deleteButtonCell = timerSettingsTable.rowController(at: 10) as? ButtonViewCell
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
                let action = WKAlertAction(title: "Ok", style: .cancel, handler: {WKInterfaceDevice.current().play(.click)})
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

extension TimerSettingsTableViewController: ButtonWithLabelDelegate {
    func buttonTapped(buttonWithLabelViewCell: ButtonWithLabelViewCell) {
        var context: contextWrapper
        if buttonWithLabelViewCell == togglPosProjectCell {
            context = contextWrapper(timerModel: workingTimer, timerType: .positive)
        }
        else {
            context = contextWrapper(timerModel: workingTimer, timerType: .negative)
        }
        pushController(withName: "projectListView", context: context)
    }
}

//
//  TimerSettingsTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class TimerSettingsTableViewController: UITableViewController {
    enum sections: Int {
        case timerName
        case timerValues
        case togglValues
        case misc
        case numberOfSections
        
        init?(indexPath: NSIndexPath) {
            self.init(rawValue: indexPath.section)
        }
    }
    struct Selected {
        var timer: [TimerType: Bool] = [.positive: false, .negative: false]
        var togglTimer: [TimerType: Bool] = [.positive: false, .negative: false]
    }
    
    var selected = Selected()
    var workingTimerID: Int!
    var workingTimerModel: TimerModel!
    var newTimer: Bool {
        if workingTimerID < GlobalVar.settings.timerList.count {
            return false
        }
        else {
            return true
        }
    }
    
    @objc func saveButtonTapped() {
        if selected.timer[.positive]! == false || selected.timer[.negative]! == false {
            print("Error: Timer value has not been filled yet")
            return
        }
        else if newTimer {
            GlobalVar.settings.timerList.append(workingTimerModel)
        }
        else {
            GlobalVar.settings.timerList[workingTimerID] = workingTimerModel
        }
        
        GlobalVar.settings.saveTimerList()
        
        if let navigation = self.navigationController,
            let timerList = navigation.viewControllers[1] as? TimerListTableViewController {
            
            timerList.tableView.reloadData()
            navigation.popViewController(animated: true)
        }
    }
        
    var posTimePickerHidden = true
    var negTimePickerHidden = true
    
    var secondRows: [Int] = []
    var posPickerView: UIPickerView!
    var negPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initTimer()
    }
    
    func initUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "subtitleCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(InputTableViewCell.self, forCellReuseIdentifier: "textInputCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: "pickerCell")
    }
    
    func initTimer() {
        if let id = workingTimerID {
            print("[Timer Settings] Working on timer \(id)")
        }
        for i in (-60 ... 60).reversed() {
            secondRows.append(i)
        }
        if newTimer {
            workingTimerModel = TimerModel()
        }
        else {
            workingTimerModel = TimerModel(timerModel: GlobalVar.settings.timerList[workingTimerID])
            selected.timer[.positive] = true
            selected.timer[.negative] = true
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.numberOfSections.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections(rawValue: section) {
        case .timerName:
            return 1
        case .timerValues:
            return 4
        case .togglValues:
            return 2
        case .misc:
            return 4
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections(rawValue: indexPath.section) {
        case .timerName:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "textInputCell", for: indexPath) as? InputTableViewCell {
                cell.inputTextField.text = workingTimerModel.timerName
                cell.inputTextField.delegate = self
                return cell
            }
        case .timerValues:
            if indexPath.row == 0 || indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
                var currType: TimerType
                
                if indexPath.row == 0 {
                    currType = .positive
                }
                else {
                    currType = .negative
                }
                
                if selected.timer[currType]! {
                    let time = abs(workingTimerModel.startTime[currType]!)
                    let seconds = time % 60
                    let minutes = time / 60
                    cell.textLabel?.text = "\(minutes)m \(seconds)s"
                }
                else {
                        cell.textLabel?.text = "Please Input Negative Time"
                }
                
                cell.imageView?.image = UIImage(systemName: "minus")!
                
                return cell
            }
            else if let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as? PickerTableViewCell {
                var time: Int = 0
                if indexPath.row == 1 {
                    posPickerView = cell.pickerView
                    if !newTimer {
                        time = workingTimerModel.startTime[.positive]!
                    }
                }
                else {
                    negPickerView = cell.pickerView
                    if !newTimer {
                        time = workingTimerModel.startTime[.negative]!
                    }
                }
                
                let minutes = abs(time / 60)
                let seconds = abs(time % 60)
                
                cell.pickerView.delegate = self
                cell.pickerView.selectRow(59 - minutes, inComponent: 0, animated: false)
                cell.pickerView.selectRow(59 - seconds, inComponent: 1, animated: false)
                
                return cell
            }
            else {
                break
            }
        case .togglValues:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
            
            if indexPath.row == 0 {
                if workingTimerModel.userDefinedTracking[.positive] != nil || selected.togglTimer[.positive]! {
                    let trackingInfo = workingTimerModel.userDefinedTracking[.positive]!
                    cell.textLabel?.text = trackingInfo.desc
                    cell.detailTextLabel?.text = trackingInfo.project.name
                }
                else {
                   print("[Timer Settings View] userDefinedTracking[.positive] has not been set")
                    cell.textLabel?.text = "Description of Positive Toggl Timer"
                    cell.detailTextLabel?.text = "Project Name of Positive Toggl Timer"
                }
                cell.imageView?.image = UIImage(systemName: "plus")!
            }
            else {
                if workingTimerModel.userDefinedTracking[.negative] != nil || selected.togglTimer[.negative]! {
                    let trackingInfo = workingTimerModel.userDefinedTracking[.negative]!
                    cell.textLabel?.text = trackingInfo.desc
                    cell.detailTextLabel?.text = trackingInfo.project.name
                }
                else {
                   print("[Timer Settings View] userDefinedTracking[.negative] has not been set")
                    cell.textLabel?.text = "Description of Positive Toggl Timer"
                    cell.detailTextLabel?.text = "Project Name of Positive Toggl Timer"
                }
                cell.imageView?.image = UIImage(systemName: "minus")!
            }

            return cell
        case .misc:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SwitchTableViewCell {
                if indexPath.row == 0 {
                    cell.settingTextLabel.text = "Auto-repeat Timer"
                    cell.settingSwitch.isOn = workingTimerModel.autoRepeat
                    cell.settingSwitch.addTarget(self, action: #selector(autoRepeatSwitched(myswitch:)), for: .valueChanged)
                }
                else if indexPath.row == 1 {
                    cell.settingTextLabel.text = "Show Alert When Timer Ends"
                    cell.settingSwitch.isOn = workingTimerModel.alertTimerEnd
                    cell.settingSwitch.addTarget(self, action: #selector(showAlertSwitched(myswitch:)), for: .valueChanged)
                }
                else if indexPath.row == 2 {
                    cell.settingTextLabel.text = "Repeat Alarm until Alert is Tapped"
                    cell.settingSwitch.isOn = workingTimerModel.repeatAlarmOption
                    cell.settingSwitch.addTarget(self, action: #selector(repeatAlarmSwitched(myswitch:)), for: .valueChanged)
                }
                else if indexPath.row == 3 {
                    cell.settingTextLabel.text = "Accumulate Passed Time Data"
                    cell.settingSwitch.isOn = workingTimerModel.accumulatePassedTime
                    cell.settingSwitch.addTarget(self, action: #selector(accumulateSwitched(myswitch:)), for: .valueChanged)
                }
                else {
                    cell.settingTextLabel.text = "ERROR: no label for this switchCell"
                }
                return cell
            }
            else {
                break
            }
        default:
            break
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections(rawValue: section) {
        case .timerName:
            return "Timer Name"
        case .timerValues:
            return "Timer Values"
        case .togglValues:
            return "Toggl Timer values"
        case .misc:
            return "Misc"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections(rawValue: indexPath.section) {
        case .timerValues:
            if indexPath.row == 1 {
                if posTimePickerHidden {
                    return 0
                }
                else {
                    return 200
                }
            }
            else if indexPath.row == 3 {
                if negTimePickerHidden {
                    return 0
                }
                else {
                    return 200
                }
            }
            else {
                break
            }
        case .togglValues:
            return 55.5
        case .misc:
            if indexPath.row == 2 && !workingTimerModel.alertTimerEnd {
                return 0
            }
            else {
                break
            }
        default:
            break
        }
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections(rawValue: indexPath.section) {
        case .timerValues:
            if indexPath.row == 0 || indexPath.row == 2 {
                let pickerIndexPath: IndexPath
                if indexPath.row == 0 {
                    pickerIndexPath = IndexPath(row: 1, section: sections.timerValues.rawValue)
                    posTimePickerHidden = !posTimePickerHidden
                    tableView.reloadRows(at: [pickerIndexPath], with: .automatic)
                    selected.timer[.positive] = true
                }
                else {
                    pickerIndexPath = IndexPath(row: 3, section: sections.timerValues.rawValue)
                    negTimePickerHidden = !negTimePickerHidden
                    selected.timer[.negative] = true
                }
                tableView.reloadRows(at: [pickerIndexPath], with: .automatic)
            }
        case .togglValues:
            var trackingType: TimerType
            if indexPath.row == 0 {
                selected.togglTimer[.positive]! = true
                trackingType = .positive
            }
            else {
                selected.togglTimer[.negative] = true
                trackingType = .negative
            }
            
            let togglTimerDetailView = TogglTimerSettingsTableViewController(style: .grouped)
            togglTimerDetailView.type = trackingType
            navigationController?.pushViewController(togglTimerDetailView, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func autoRepeatSwitched(myswitch: UISwitch) {
        workingTimerModel.autoRepeat = myswitch.isOn
        if myswitch.isOn {
            print("[Timer Settings View] Auto-repeat switch turned on")
        }
        else {
            print("[Timer Settings View] Auto-repeat switch turned off")
        }
    }
    
    @objc func accumulateSwitched(myswitch: UISwitch) {
        workingTimerModel.accumulatePassedTime = myswitch.isOn
        if myswitch.isOn {
            print("[Timer Settings View] Accumulate Passed Time switch turned on")
        }
        else {
            print("[Timer Settings View] Accumulate Passed Time switch turned off")
        }
    }
    
    @objc func showAlertSwitched(myswitch: UISwitch) {
        workingTimerModel.alertTimerEnd = myswitch.isOn
        if myswitch.isOn {
            print("[Timer Settings View] Show alert switch turned on")
        }
        else {
            print("[Timer Settings View] Show alert switch turned off")
        }
        let repeatAlarmIndexPath = IndexPath(row: 2, section: sections.misc.rawValue)
        tableView.reloadRows(at: [repeatAlarmIndexPath], with: .none)
    }
    
    @objc func repeatAlarmSwitched(myswitch: UISwitch) {
        workingTimerModel.repeatAlarmOption = myswitch.isOn
        if myswitch.isOn {
            print("[Timer Settings View] Repeat Alarm switch turned on")
        }
        else {
            print("[Timer Settings View] Repeat Alarm switch turned off")
        }
    }
}

extension TimerSettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    enum components: Int {
        case minVal
        case minLabel
        case secVal
        case secLabel
        case numberOfComponents
        
        init?(indexPath: NSIndexPath) {
            self.init(rawValue: indexPath.section)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components.numberOfComponents.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch components(rawValue: component) {
        case .minVal:
            return 60
        case .minLabel:
            return 1
        case .secVal:
            return 60
        case .secLabel:
            return 1
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch components(rawValue: component) {
        case .minVal:
            return String(59 - row)
        case .minLabel:
            return "m"
        case .secVal:
            return String(59 - row)
        case .secLabel:
            return "s"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var seconds: Int = 0
        var minutes: Int = 0
        
        switch components(rawValue: component) {
        case .minVal:
            minutes = 59 - row
            seconds = 59 - pickerView.selectedRow(inComponent: components.secVal.rawValue)
        case .secVal:
            seconds = 59 - row
            minutes = 59 - pickerView.selectedRow(inComponent: components.minVal.rawValue)
        default:
            break
        }
        
        seconds += minutes * 60
        
        print("[Timer Settings View] Picked \(seconds)")
        
        if pickerView == posPickerView {
            workingTimerModel.startTime[.positive] = seconds
            let labelIndexPath = IndexPath(row: 0, section: sections.timerValues.rawValue)
            tableView.reloadRows(at: [labelIndexPath], with: .automatic)
        }
        else {
            workingTimerModel.startTime[.negative] = -seconds
            let labelIndexPath = IndexPath(row: 2, section: sections.timerValues.rawValue)
            tableView.reloadRows(at: [labelIndexPath], with: .automatic)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let timeWidth: CGFloat = 40
        let labelWidth: CGFloat = 40
        switch components(rawValue: component) {
        case .minVal:
            return timeWidth
        case .minLabel:
            return labelWidth
        case .secVal:
            return timeWidth
        case .secLabel:
            return labelWidth
        default:
            return 0
        }
    }
}

extension TimerSettingsTableViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            workingTimerModel.timerName = text
        }
    }
    
    //TODO: also hide keyboard when tapping outside of textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

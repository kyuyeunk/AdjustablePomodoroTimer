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
        case alarmSounds
        case togglValues
        case misc
        case numberOfSections
        
        init?(indexPath: NSIndexPath) {
            self.init(rawValue: indexPath.section)
        }
    }
    
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
    
    //MARK: - UIButton
    @objc func saveButtonTapped() {
        if newTimer {
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
    
    
    // MARK: UIInitialization
    
    var posTimePickerHidden = true
    var negTimePickerHidden = true
    var maxTimePickerHidden = true
    
    var secondRows: [Int] = []
    var posPickerView: UIPickerView!
    var negPickerView: UIPickerView!
    var maxPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initTimer()
    }
    
    func initUI() {
        navigationItem.title = "Timer Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "subtitleCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
        tableView.register(InputTableViewCell.self, forCellReuseIdentifier: "textInputCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: "pickerCell")
        tableView.register(RightDetailTableViewCell.self, forCellReuseIdentifier: "rightDetailCell")
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
        }
    }

    //MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.numberOfSections.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections(rawValue: section) {
        case .timerName:
            return 1
        case .timerValues:
            return 6
        case .alarmSounds:
            return 2
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
                cell.inputTextField.returnKeyType = .done
                return cell
            }
        case .timerValues:
            if indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                
                if indexPath.row == 2 || indexPath.row == 4 {
                    var currType: TimerType
                    if indexPath.row == 2 {
                        cell.textLabel?.text = "Positive Time"
                        currType = .positive
                        cell.imageView?.image = UIImage(systemName: "plus.circle")!
                    }
                    else {
                        cell.textLabel?.text = "Negative Time"
                        currType = .negative
                        cell.imageView?.image = UIImage(systemName: "minus.circle")!
                    }
                    let time = abs(workingTimerModel.startTime[currType]!)
                    let seconds = time % 60
                    let minutes = time / 60
                    cell.detailTextLabel?.text = "\(minutes)m \(seconds)s"
                }
                else {
                    cell.textLabel?.text = "Maximum Minutes"
                    cell.detailTextLabel?.text = "\(workingTimerModel.maxMinutes)m"
                    cell.imageView?.image = UIImage(systemName: "chevron.up.circle")!
                }
                
                return cell
            }
            else if let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as? PickerTableViewCell {
                if indexPath.row == 3 || indexPath.row == 5 {
                    var time: Int = 0
                    if indexPath.row == 3 {
                        posPickerView = cell.pickerView
                        time = workingTimerModel.startTime[.positive]!
                    }
                    else {
                        negPickerView = cell.pickerView
                        time = workingTimerModel.startTime[.negative]!
                    }
                    
                    let minutes = abs(time) / 60
                    let seconds = abs(time) % 60
                    
                    cell.pickerView.delegate = self
                    cell.pickerView.selectRow(workingTimerModel.maxMinutes - minutes, inComponent: 0, animated: false)
                    cell.pickerView.selectRow(59 - seconds, inComponent: 2, animated: false)
                }
                else {
                    maxPickerView = cell.pickerView
                    var minutes: Int = 12
                    if !newTimer {
                        minutes = workingTimerModel.maxMinutes
                    }
                    
                    cell.pickerView.delegate = self
                    cell.pickerView.selectRow(60 - minutes, inComponent: 0, animated: false)
                }
                
                return cell
            }
            else {
                break
            }
        case .alarmSounds:
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell", for: indexPath)
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(systemName: "plus.circle")!
                cell.textLabel?.text = "Positive Sound"
                cell.detailTextLabel?.text = GlobalVar.alarmSounds.list[workingTimerModel.timerAlarmID[.positive]!].alarmName
            }
            else {
                cell.imageView?.image = UIImage(systemName: "minus.circle")!
                cell.textLabel?.text = "Negative Sound"
                cell.detailTextLabel?.text = GlobalVar.alarmSounds.list[workingTimerModel.timerAlarmID[.negative]!].alarmName
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        case .togglValues:
            let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            
            if indexPath.row == 0 {
                if workingTimerModel.userDefinedTracking[.positive] != nil {
                    let trackingInfo = workingTimerModel.userDefinedTracking[.positive]!
                    cell.textLabel?.text = trackingInfo.desc
                    cell.detailTextLabel?.text = trackingInfo.project.name
                }
                else {
                   print("[Timer Settings View] userDefinedTracking[.positive] has not been set")
                    cell.textLabel?.text = "Description of Positive Toggl Timer"
                    cell.detailTextLabel?.text = "Project Name of Positive Toggl Timer"
                }
                cell.imageView?.image = UIImage(systemName: "plus.circle")!
            }
            else {
                if workingTimerModel.userDefinedTracking[.negative] != nil {
                    let trackingInfo = workingTimerModel.userDefinedTracking[.negative]!
                    cell.textLabel?.text = trackingInfo.desc
                    cell.detailTextLabel?.text = trackingInfo.project.name
                }
                else {
                   print("[Timer Settings View] userDefinedTracking[.negative] has not been set")
                    cell.textLabel?.text = "Description of Positive Toggl Timer"
                    cell.detailTextLabel?.text = "Project Name of Positive Toggl Timer"
                }
                cell.imageView?.image = UIImage(systemName: "minus.circle")!
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
        case .alarmSounds:
            return "Alarm Sounds"
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
            if indexPath.row == 3 {
                if posTimePickerHidden {
                    return 0
                }
                else {
                    return 200
                }
            }
            else if indexPath.row == 5 {
                if negTimePickerHidden {
                    return 0
                }
                else {
                    return 200
                }
            }
            else if indexPath.row == 1 {
                if maxTimePickerHidden {
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
        default:
            break
        }
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections(rawValue: indexPath.section) {
        case .timerValues:
            if indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 {
                let pickerIndexPath: IndexPath
                if indexPath.row == 2 {
                    pickerIndexPath = IndexPath(row: 3, section: sections.timerValues.rawValue)
                    posTimePickerHidden = !posTimePickerHidden
                }
                else if indexPath.row == 4 {
                    pickerIndexPath = IndexPath(row: 5, section: sections.timerValues.rawValue)
                    negTimePickerHidden = !negTimePickerHidden
                }
                else {
                    maxTimePickerHidden = !maxTimePickerHidden
                    pickerIndexPath = IndexPath(row: 1, section: sections.timerValues.rawValue)
                }
                tableView.reloadRows(at: [pickerIndexPath], with: .automatic)
            }
        case .alarmSounds:
            let alarmSoundsList = AlarmSoundsTableViewController(style: .grouped)
            
            if indexPath.row == 0 {
                alarmSoundsList.selectedAlarmID = workingTimerModel.timerAlarmID[.positive]!
                alarmSoundsList.type = .positive
            }
            else {
                alarmSoundsList.selectedAlarmID = workingTimerModel.timerAlarmID[.negative]!
                alarmSoundsList.type = .negative
            }
 
            navigationController?.pushViewController(alarmSoundsList, animated: true)
        case .togglValues:
            if GlobalVar.settings.togglLoggedIn {
                var trackingType: TimerType
                if indexPath.row == 0 {
                    trackingType = .positive
                }
                else {
                    trackingType = .negative
                }
                
                let togglTimerDetailView = TogglTimerSettingsTableViewController(style: .grouped)
                togglTimerDetailView.type = trackingType
                navigationController?.pushViewController(togglTimerDetailView, animated: true)
            }
            else {
                print("[Timer Settings] Toggl was not logged in")
                var alert: UIAlertController
                var okButton: UIAlertAction
                
                let message = "Go To Settings and Log In Toggl"
                
                alert = UIAlertController(title: "Toggl Not Logged In",
                                          message: message, preferredStyle: .alert)
                
                okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(okButton)
                
                present(alert, animated: true, completion: nil)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Switch Functions
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

//MARK: - PickerView
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
        if maxPickerView == pickerView {
            return 2
        }
        else {
        return components.numberOfComponents.rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == maxPickerView {
            switch components(rawValue: component) {
            case .minVal:
                return 60
            case .minLabel:
                return 1
            default:
                return 0
            }
        }
        else {
            switch components(rawValue: component) {
            case .minVal:
                return workingTimerModel.maxMinutes + 1
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
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == maxPickerView {
            switch components(rawValue: component) {
            case .minVal:
                return String(60 - row)
            case .minLabel:
                return "m"
            default:
                return nil
            }
        }
        else {
            switch components(rawValue: component) {
            case .minVal:
                return String(workingTimerModel.maxMinutes - row)
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
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == maxPickerView {
            let minutes = 60 - row
            workingTimerModel.maxMinutes = minutes
            let labelIndexPath = IndexPath(row: 0, section: sections.timerValues.rawValue)
            tableView.reloadRows(at: [labelIndexPath], with: .automatic)
                   
            if workingTimerModel.maxMinutes * 60 < workingTimerModel.startTime[.positive]! {
                workingTimerModel.startTime[.positive] = workingTimerModel.maxMinutes * 60
                posPickerView.selectRow(0, inComponent: 0, animated: true)
                posPickerView.selectRow(59, inComponent: 2, animated: true)
                let posLabelIndexPath = IndexPath(row: 2, section: sections.timerValues.rawValue)
                tableView.reloadRows(at: [posLabelIndexPath], with: .automatic)
            }
            if workingTimerModel.maxMinutes * 60 < -workingTimerModel.startTime[.negative]! {
                workingTimerModel.startTime[.negative] = -workingTimerModel.maxMinutes * 60
                negPickerView.selectRow(0, inComponent: 0, animated: true)
                negPickerView.selectRow(59, inComponent: 2, animated: true)
                let negLabelIndexPath = IndexPath(row: 4, section: sections.timerValues.rawValue)
                tableView.reloadRows(at: [negLabelIndexPath], with: .automatic)
            }
            
            posPickerView.reloadComponent(0)
            negPickerView.reloadComponent(0)
        }
        else {
            var seconds: Int = 0
            var minutes: Int = 0
            
            switch components(rawValue: component) {
            case .minVal:
                minutes = workingTimerModel.maxMinutes - row
                seconds = 59 - pickerView.selectedRow(inComponent: components.secVal.rawValue)
            case .secVal:
                seconds = 59 - row
                minutes = workingTimerModel.maxMinutes - pickerView.selectedRow(inComponent: components.minVal.rawValue)
            default:
                break
            }
            
            if minutes >= workingTimerModel.maxMinutes {
                minutes = workingTimerModel.maxMinutes
                seconds = 0
                pickerView.selectRow(59 - seconds, inComponent: components.secVal.rawValue, animated: true)
            }
            
            seconds += minutes * 60
            
            print("[Timer Settings View] Picked \(seconds)")
            
            if pickerView == posPickerView {
                workingTimerModel.startTime[.positive] = seconds
                let labelIndexPath = IndexPath(row: 2, section: sections.timerValues.rawValue)
                tableView.reloadRows(at: [labelIndexPath], with: .automatic)
            }
            else {
                workingTimerModel.startTime[.negative] = -seconds
                let labelIndexPath = IndexPath(row: 4, section: sections.timerValues.rawValue)
                tableView.reloadRows(at: [labelIndexPath], with: .automatic)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let timeWidth: CGFloat = 60
        let labelWidth: CGFloat = 60
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

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
        var posTimer = false
        var negTimer = false
        var posTogglTimer = false
        var negTogglTimer = false
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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if selected.posTimer == false || selected.negTimer == false {
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
            workingTimerModel = GlobalVar.settings.timerList[workingTimerID]
            selected.posTimer = true
            selected.negTimer = true
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
            return 1
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
                if indexPath.row == 0 {
                    if selected.posTimer {
                        cell.textLabel?.text = String(workingTimerModel.posStartTime)
                    }
                    else {
                        cell.textLabel?.text = "Please Input Positive Time"
                        
                    }
                    cell.imageView?.image = UIImage(systemName: "plus")!
                }
                else if indexPath.row == 2 {
                    if selected.negTimer {
                        cell.textLabel?.text = String(workingTimerModel.negStartTime)
                    }
                    else {
                        cell.textLabel?.text = "Please Input Positive Time"
                    }
                    cell.imageView?.image = UIImage(systemName: "minus")!
                }
                
                return cell
            }
            else if let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as? PickerTableViewCell {
                var currRow: Int = 60
                if indexPath.row == 1 {
                    posPickerView = cell.pickerView
                    if !newTimer {
                        currRow = 60 - workingTimerModel.posStartTime
                    }
                }
                else {
                    negPickerView = cell.pickerView
                    if !newTimer {
                        currRow = 60 - workingTimerModel.negStartTime
                    }
                }
                
                cell.pickerView.delegate = self
                cell.pickerView.selectRow(currRow, inComponent: 0, animated: false)
                
                return cell
            }
            else {
                break
            }
        case .togglValues:
            let cell = tableView.dequeueReusableCell(withIdentifier: "togglTimerSettingsCell", for: indexPath)
            
            if indexPath.row == 0 {
                if workingTimerModel.userDefinedTracking[.positive] != nil || selected.posTogglTimer {
                    let trackingInfo = workingTimerModel.userDefinedTracking[.positive]!
                    cell.textLabel?.text = trackingInfo.desc
                    cell.detailTextLabel?.text = trackingInfo.project.name
                }
                else {
                   print("ERROR: userDefinedTracking[.positive] has not been set")
                    cell.textLabel?.text = "Description of Positive Toggl Timer"
                    cell.detailTextLabel?.text = "Project Name of Positive Toggl Timer"
                }
                cell.imageView?.image = UIImage(systemName: "plus")!
            }
            else {
                if workingTimerModel.userDefinedTracking[.negative] != nil || selected.negTogglTimer {
                    let trackingInfo = workingTimerModel.userDefinedTracking[.negative]!
                    cell.textLabel?.text = trackingInfo.desc
                    cell.detailTextLabel?.text = trackingInfo.project.name
                }
                else {
                   print("ERROR: userDefinedTracking[.negative] has not been set")
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
            if indexPath.section == 1 {
                return 55.5
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
                    selected.posTimer = true
                }
                else {
                    pickerIndexPath = IndexPath(row: 3, section: sections.timerValues.rawValue)
                    negTimePickerHidden = !negTimePickerHidden
                    selected.negTimer = true
                }
                tableView.reloadRows(at: [pickerIndexPath], with: .automatic)
            }
        case .togglValues:
            var trackingType: TrackingType
            if indexPath.row == 0 {
                selected.posTogglTimer = true
                trackingType = .positive
            }
            else {
                selected.negTogglTimer = true
                trackingType = .negative
            }
            performSegue(withIdentifier: "TogglTimerDetailSegue", sender: trackingType)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     @objc func autoRepeatSwitched(myswitch: UISwitch) {
        workingTimerModel.autoRepeat = myswitch.isOn
        if myswitch.isOn {
            print("[Settings View] Auto-repeat switch turned on")
        }
        else {
            print("[Settings View] Auto-repeat switch turned off")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let togglTimer = segue.destination as? TogglTimerSettingsTableViewController,
            let type = sender as? TrackingType {
            togglTimer.type = type
        }
    }
}

extension TimerSettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return secondRows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(secondRows[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == posPickerView {
            workingTimerModel.posStartTime = secondRows[row]
            let labelIndexPath = IndexPath(row: 0, section: sections.timerValues.rawValue)
            tableView.reloadRows(at: [labelIndexPath], with: .automatic)
        }
        else {
            workingTimerModel.negStartTime = secondRows[row]
            let labelIndexPath = IndexPath(row: 2, section: sections.timerValues.rawValue)
            tableView.reloadRows(at: [labelIndexPath], with: .automatic)
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

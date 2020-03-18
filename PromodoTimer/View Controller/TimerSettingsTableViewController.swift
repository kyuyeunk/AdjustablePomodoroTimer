//
//  TimerSettingsTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class TimerSettingsTableViewController: UITableViewController {

    var workingTimerID: Int!
    
    var posTimePickerHidden = true
    var negTimePickerHidden = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = workingTimerID {
            print("[Timer Settings] Working on timer \(id)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else if section == 1 {
            return 2
        }
        else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
                if workingTimerID < GlobalVar.timerList.count {
                    if indexPath.row == 0 {
                        cell.textLabel?.text = String(GlobalVar.timerList[workingTimerID].posStartTime)
                        cell.imageView?.image = UIImage(systemName: "plus")!
                        
                    }
                    else if indexPath.row == 2 {
                        cell.textLabel?.text = String(GlobalVar.timerList[workingTimerID].negStartTime)
                        cell.imageView?.image = UIImage(systemName: "minus")!
                    }
                }
                else {
                    if indexPath.row == 0 {
                        cell.textLabel?.text = "Please Input Positive Time"
                        cell.imageView?.image = UIImage(systemName: "plus")!
                    }
                    else if indexPath.row == 2{
                        cell.textLabel?.text = "Please Input Positive Time"
                        cell.imageView?.image = UIImage(systemName: "minus")!
                    }
                }

                return cell
            }
            else if let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as? PickerTableViewCell {
                for i in (-60 ... 60).reversed() {
                    cell.dataSource.append(i)
                }
                
                return cell
            }
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "togglTimerSettingsCell", for: indexPath)
            
            var type: TrackingType
            var image: UIImage
            if (indexPath.row == 0) {
                type = .positive
                image = UIImage(systemName: "plus")!
            }
            else {
                type = .negative
                image = UIImage(systemName: "minus")!
            }
            
            cell.imageView?.image = image
            if workingTimerID < GlobalVar.timerList.count, let trackingInfo = GlobalVar.timerList[0].userDefinedTracking[type] {
                cell.textLabel?.text = trackingInfo.desc
                cell.detailTextLabel?.text = trackingInfo.project.name
            }
            else {
                print("ERROR: userDefinedTracking[] has not been set")
                if (indexPath.row == 0) {
                        cell.textLabel?.text = "Description of Positive Toggl Timer"
                        cell.detailTextLabel?.text = "Project Name of Positive Toggl Timer"
                }
                else if (indexPath.row == 1) {
                cell.textLabel?.text = "Description of Negative Toggl Timer"
                cell.detailTextLabel?.text = "Project Name of Negative Toggl Timer"
                }
            }
            
            return cell
        }
        else if let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SwitchTableViewCell {
            if indexPath.row == 0 {
                cell.settingTextLabel.text = "Auto-repeat Timer"
                cell.settingSwitch.isOn = GlobalVar.settings.autoRepeat
                cell.settingSwitch.addTarget(self, action: #selector(autoRepeatSwitched(myswitch:)), for: .valueChanged)
            }
            else {
                cell.settingTextLabel.text = "What should I do?"
            }
            
            return cell
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        }

        return tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Timer Values"
        }
        else if section == 1 {
            return "Toggl Timer Values"
        }
        else {
            return "Misc"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
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
                return 45
            }
        }
        else if indexPath.section == 1 {
            return 55.5
        }
        else {
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 2){
            let pickerIndexPath: IndexPath
            if indexPath.row == 0 {
                pickerIndexPath = IndexPath(row: 1, section: 0)
                posTimePickerHidden = !posTimePickerHidden
                tableView.reloadRows(at: [pickerIndexPath], with: .automatic)
            }
            else {
                pickerIndexPath = IndexPath(row: 3, section: 0)
                negTimePickerHidden = !negTimePickerHidden
            }
            tableView.reloadRows(at: [pickerIndexPath], with: .automatic)
        }
        else if indexPath.section == 1 {
            performSegue(withIdentifier: "TogglTimerDetailSegue", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     @objc func autoRepeatSwitched(myswitch: UISwitch) {
        GlobalVar.timerList[workingTimerID].autoRepeat = myswitch.isOn
        if myswitch.isOn {
            print("[Settings View] Auto-repeat switch turned on")
        }
        else {
            print("[Settings View] Auto-repeat switch turned off")
        }
    }
}

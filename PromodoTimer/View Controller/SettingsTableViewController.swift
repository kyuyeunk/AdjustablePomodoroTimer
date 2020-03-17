//
//  SettingsTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

enum sections {
    case togglID
    case togglTimersSettings
    case timerSettings
}
class SettingsTableViewController: UITableViewController {
    var togglLoggedIn: Bool {
        return GlobalVar.settings.auth != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Toggl ID"
        }
        else if section == 1 && togglLoggedIn {
            return "Toggl Timer"
        }
        else if section == 2 {
            return "Timer Settings"
        }
        else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "LogInSegue", sender: nil)
        }
        else {
           performSegue(withIdentifier: "TimerDetailSegue", sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
            if let id = GlobalVar.settings.id {
                    cell.textLabel?.text = id
            }
            else {
                cell.textLabel?.text = "Please input ID/PW"
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timerValueCell", for: indexPath)
            
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
            if let trackingInfo = GlobalVar.timerList[GlobalVar.currTimer].userDefinedTracking[type] {
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
            return tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let timerDetail = segue.destination as? TimerDetailTableViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            if indexPath.row == 0 {
                timerDetail.type = .positive
            }
            else {
                timerDetail.type = .negative
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if togglLoggedIn {
                return 55.5
            }
            else {
                return 0
            }
        }
        else {
            return 43.5
        }
    }
    
    @objc func autoRepeatSwitched(myswitch: UISwitch) {
        GlobalVar.settings.autoRepeat = myswitch.isOn
        if myswitch.isOn {
            print("[Settings View] Auto-repeat switch turned on")
        }
        else {
            print("[Settings View] Auto-repeat switch turned off")
        }
    }
}

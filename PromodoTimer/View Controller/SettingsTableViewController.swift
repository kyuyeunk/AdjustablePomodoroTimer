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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return 1
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Toggl ID"
        }
        else if section == 1 {
            return "Miscs"
        }
        else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let loginView = LogInViewController()
            navigationController?.pushViewController(loginView, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
                if let id = GlobalVar.settings.togglCredential.id {
                    cell.textLabel?.text = id
                }
                else {
                    cell.textLabel?.text = "Please input ID/PW"
                }
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SwitchTableViewCell {
                cell.settingTextLabel.text = "Keep Display On"
                cell.settingSwitch.isOn = GlobalVar.settings.dontSleep
                cell.settingSwitch.addTarget(self, action: #selector(dontSleepSwitched(myswitch:)), for: .valueChanged)
                return cell
            }
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43.5
    }
    
    @objc func dontSleepSwitched(myswitch: UISwitch) {
        GlobalVar.settings.dontSleep = myswitch.isOn
        if myswitch.isOn {
            print("[Settings View] Don't Sleep switch turned on")
        }
        else {
            print("[Settings View] Don't Sleep switch turned off")
        }
    }
}

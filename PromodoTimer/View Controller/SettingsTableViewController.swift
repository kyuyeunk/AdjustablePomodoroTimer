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
    enum sections: Int {
        case toggl
        case misc
        case numberOfSections
        
        init?(indexPath: NSIndexPath) {
            self.init(rawValue: indexPath.section)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "switchCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections(rawValue: section) {
        case .toggl:
            return 2
        case .misc:
            return 1
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.numberOfSections.rawValue
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections(rawValue: section) {
        case .toggl:
            return "Toggl ID"
        case .misc:
            return "Miscs"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections(rawValue: indexPath.section) {
        case .toggl:
            if indexPath.row == 0 {
                let loginView = LogInViewController()
                navigationController?.pushViewController(loginView, animated: true)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections(rawValue: indexPath.section) {
        case .toggl:
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
            if indexPath.row == 0 {
                if let id = GlobalVar.settings.togglCredential.id {
                    cell.textLabel?.text = id
                }
                else {
                    cell.textLabel?.text = "Please input ID/PW"
                }
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.textLabel?.text = "Log Out"
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.textAlignment = .center
            }
            
            return cell
        case .misc:
            if indexPath.row == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SwitchTableViewCell {
                cell.settingTextLabel.text = "Keep Display On"
                cell.settingSwitch.isOn = GlobalVar.settings.dontSleep
                cell.settingSwitch.addTarget(self, action: #selector(dontSleepSwitched(myswitch:)), for: .valueChanged)
                return cell
            }
        default:
            break
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections(rawValue: indexPath.section) {
        case .toggl:
            if indexPath.row == 1 && !GlobalVar.settings.togglLoggedIn {
                return 0
            }
        default:
            break
        }
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

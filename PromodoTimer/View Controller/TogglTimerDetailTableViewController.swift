//
//  TimerDetailTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class TogglTimerSettingsTableViewController: UITableViewController {
    enum sections: Int {
        case description
        case selectedProject
        case projectList
        case numberOfSections
        
        init?(indexPath: NSIndexPath) {
            self.init(rawValue: indexPath.section)
        }
    }
    var type: TrackingType!
    var selectedProject: projectInfo?
    var desc: String?

    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let selectedProject = selectedProject, let desc = desc else {
            print("Error: timer detail has not been filled")
            return
        }
        
        let selectedInfo = trackingInfo(project: selectedProject, desc: desc)
        if let navigation = self.navigationController,
            let timerSettings = navigation.viewControllers[2] as? TimerSettingsTableViewController {
            
            timerSettings.workingTimerModel.userDefinedTracking[type] = selectedInfo
            timerSettings.tableView.reloadData()
            navigation.popViewController(animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.numberOfSections.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections(rawValue: section) {
        case .projectList:
            return GlobalVar.settings.projects.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections(rawValue: section) {
        case .description:
            return "Description of the Timer"
        case .selectedProject:
            return "Selected Project of the Timer"
        case .projectList:
            return "List of Selectable Projects"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections(rawValue: indexPath.section) {
        case .description:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as? InputTableViewCell {
                cell.inputTextField.delegate = self
                return cell
            }
            break
        case .selectedProject:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            if let selectedProject = selectedProject {
                cell.textLabel?.text = selectedProject.name
            }
            else {
                cell.textLabel?.text = "Please Select Project"
            }
            return cell
        case .projectList:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            let project = GlobalVar.settings.projects[indexPath.row]
            cell.textLabel?.text = project.name
            
            return cell
        default:
            break
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections(rawValue: indexPath.section) {
        case .projectList:
            selectedProject = GlobalVar.settings.projects[indexPath.row]
            let projectNameindexPath = IndexPath(row: 0, section: 1)
            tableView.reloadRows(at: [projectNameindexPath], with: .automatic)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TogglTimerSettingsTableViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        desc = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

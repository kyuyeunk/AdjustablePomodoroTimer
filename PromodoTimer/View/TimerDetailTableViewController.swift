//
//  TimerDetailTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class TimerDetailTableViewController: UITableViewController {

    var type: TrackingType = .positive
    var selectedProject: projectInfo?
    var desc: String?

    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let selectedProject = selectedProject, let desc = desc else {
            print("Error: timer detail has not been filled")
            return
        }
        
        let selectedInfo = trackingInfo(project: selectedProject, desc: desc)
        if let navigation = self.navigationController,
            let settings = navigation.viewControllers[1] as? SettingsTableViewController {
            
            GlobalVar.timeController.toggl.userDefinedTracking[type] = selectedInfo
            settings.tableView.reloadData()
            navigation.popViewController(animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 2 {
            return GlobalVar.timeController.toggl.projects.count
        }
        else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Description of the Timer"
        }
        else if section == 1 {
            return "Selected Project of the Timer"
        }
        else {
            return "List of Selectable Projects"
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0,
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as? InputTableViewCell {
            cell.inputTextField.delegate = self
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
            if indexPath.section == 2 {
                let project = GlobalVar.timeController.toggl.projects[indexPath.row]
                cell.textLabel?.text = project.name
            }
            else {
                if let selectedProject = selectedProject {
                    cell.textLabel?.text = selectedProject.name
                }
                else {
                    cell.textLabel?.text = "Please Select Project"
                }
            }
             return cell
        }  
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            selectedProject = GlobalVar.timeController.toggl.projects[indexPath.row]
            let projectNameindexPath = IndexPath(row: 0, section: 1)
            tableView.reloadRows(at: [projectNameindexPath], with: .automatic)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TimerDetailTableViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        desc = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

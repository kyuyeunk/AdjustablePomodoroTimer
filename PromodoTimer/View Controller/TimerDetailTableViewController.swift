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
    var desc: String? = "Testing"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

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
        let cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath)
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
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
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            selectedProject = GlobalVar.timeController.toggl.projects[indexPath.row]
            let projectNameindexPath = IndexPath(row: 0, section: 1)
            tableView.reloadRows(at: [projectNameindexPath], with: .automatic)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

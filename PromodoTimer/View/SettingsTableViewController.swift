//
//  SettingsTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var togglLoggedIn: Bool {
        return GlobalVar.settings.auth != ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return 2
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Toggl ID"
        }
        else if section == 1 && togglLoggedIn {
            return "Toggl Timer"
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
        var cell: UITableViewCell

        if indexPath.section == 0 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
            cell.textLabel?.text = GlobalVar.settings.id
        }
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath)
            
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
            if let trackingInfo = GlobalVar.settings.userDefinedTracking[type] {
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
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        }
        
        return cell
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

//
//  TimerListTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/17.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class TimerListTableViewController: UITableViewController {

    @IBAction func addButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "TimerSettingsSegue", sender: GlobalVar.timerList.count)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GlobalVar.timerList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timerCell", for: indexPath)
        let timer = GlobalVar.timerList[indexPath.row]
        cell.textLabel?.text = timer.timerName
        if indexPath.row == GlobalVar.settings.currTimer {
        cell.imageView?.image = UIImage(systemName: "circle.fill")!
        }
        else {
        cell.imageView?.image = UIImage(systemName: "circle")!
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GlobalVar.settings.currTimer = indexPath.row
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if GlobalVar.timerList.count == 1 {
                DispatchQueue.main.async {
                    var alert: UIAlertController
                    var okButton: UIAlertAction

                    alert = UIAlertController(title: "Error",
                        message: "There should be at least one timer", preferredStyle: .alert)
                    okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                GlobalVar.timerList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let timerSettings = segue.destination as? TimerSettingsTableViewController, let timerID = sender as? Int {
            timerSettings.workingTimerID = timerID
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "TimerSettingsSegue", sender: indexPath.row)
    }

}

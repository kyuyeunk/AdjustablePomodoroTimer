//
//  LogInTableViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/14.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class LogInTableViewController: UITableViewController {

    @IBAction func doneButtonPressed(_ sender: Any) {
        guard let id = idTextField.text else {
            print("Error: ID is not filled")
            return
        }
        guard let pw = pwTextField.text else {
            print("Error: PW is not filled")
            return
        }
    
        GlobalVar.timeController.toggl.setAuth(id: id, pw: pw) { (valid) in
            DispatchQueue.main.async {
                var alert: UIAlertController
                var okButton: UIAlertAction
                if valid {
                    alert = UIAlertController(title: "Toggl Authentication",
                        message: "Auth is set to \(GlobalVar.timeController.toggl.auth)", preferredStyle: .alert)
                    okButton = UIAlertAction(title: "Ok", style: .cancel) { (action) in
                        if let navigation = self.navigationController {
                            if let settings = navigation.viewControllers[1] as? SettingsTableViewController {
                                settings.togglIDLabel.text = GlobalVar.timeController.toggl.id
                                navigation.popViewController(animated: true)
                            }
                        }
                    }
                }
                else {
                    alert = UIAlertController(title: "Error",
                        message: "ID/PW is not valid", preferredStyle: .alert)
                    okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                }
                
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

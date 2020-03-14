//
//  LogInViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBAction func loginButtonPressed(_ sender: Any) {
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
                        if let navigation = self.navigationController,
                            let settings = navigation.viewControllers[1] as? SettingsTableViewController {
                            
                            settings.togglIDLabel.text = GlobalVar.timeController.toggl.id
                            navigation.popViewController(animated: true)
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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  LogInViewController.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    private var loginStackView = UIStackView()
    private var togglLabel = UILabel()
    private var idStackView = UIStackView()
    private var pwStackView = UIStackView()
    private var idLabel = UILabel()
    private var idTextField = UITextField()
    private var pwLabel = UILabel()
    private var pwTextField = UITextField()
    private var loginButton = UIButton(type: .system)
    
    @objc func loginButtonPressed() {
        guard let id = idTextField.text else {
            print("Error: ID is not filled")
            return
        }
        guard let pw = pwTextField.text else {
            print("Error: PW is not filled")
            return
        }
    
        GlobalVar.toggl.setAuth(id: id, pw: pw) { (valid) in
            DispatchQueue.main.async {
                var alert: UIAlertController
                var okButton: UIAlertAction
                if valid, let auth = GlobalVar.settings.togglCredential.auth {
                    
                    alert = UIAlertController(title: "Toggl Authentication",
                        message: "Auth is set to \(auth)", preferredStyle: .alert)
                    okButton = UIAlertAction(title: "Ok", style: .cancel) { (action) in
                        if let navigation = self.navigationController,
                            let settings = navigation.viewControllers[1] as? SettingsTableViewController {
                            
                            settings.tableView.reloadData()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        initUIAttributes()
        initUIConstraints()
        initUIFeatures()
    }
    
    private func addViews() {
        view.addSubview(loginStackView)
        
        loginStackView.addArrangedSubview(togglLabel)
        loginStackView.addArrangedSubview(idStackView)
        loginStackView.addArrangedSubview(pwStackView)
        loginStackView.addArrangedSubview(loginButton)
        
        idStackView.addArrangedSubview(idLabel)
        idStackView.addArrangedSubview(idTextField)
        
        pwStackView.addArrangedSubview(pwLabel)
        pwStackView.addArrangedSubview(pwTextField)
    }
    
    private func initUIAttributes() {
        navigationItem.title = "Login Toggl"
        if self.traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
        
        loginStackView.axis = .vertical
        loginStackView.alignment = .fill
        loginStackView.spacing = 12
        
        togglLabel.text = "Toggl"
        togglLabel.font = togglLabel.font.withSize(30)
        togglLabel.textAlignment = .center
        
        idLabel.text = "ID"
        idTextField.borderStyle = .roundedRect
        idTextField.keyboardType = .emailAddress
        idTextField.autocapitalizationType = .none
        
        pwLabel.text = "PW"
        pwTextField.borderStyle = .roundedRect
        pwTextField.isSecureTextEntry = true
        
        loginButton.setTitle("Log In", for: .normal)
        loginButton.titleLabel?.font = loginButton.titleLabel?.font.withSize(20)
        
        idStackView.axis = .horizontal
        pwStackView.axis = .horizontal
    }
    
    private func initUIConstraints() {
        loginStackView.translatesAutoresizingMaskIntoConstraints = false
        loginStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        loginStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        loginStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 100).isActive = true
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        pwLabel.translatesAutoresizingMaskIntoConstraints = false
        pwLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func initUIFeatures() {
        idTextField.delegate = self
        pwTextField.delegate = self
        
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

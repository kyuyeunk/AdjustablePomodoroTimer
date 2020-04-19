//
//  SettingsViewController.swift
//  
//
//  Created by Kyu Yeun Kim on 2020/04/14.
//

import WatchKit
import WatchConnectivity

class SettingsViewController: WKInterfaceController {
    @IBOutlet weak var settingsTable: WKInterfaceTable!
    
    private var togglButtonCell: ButtonWithLabelViewCell!
    private var tickingSoundSwitchCell: SwitchSettingViewCell!
    private var syncButtonCell: ButtonViewCell!
    
    override func awake(withContext context: Any?) {
         super.awake(withContext: context)
     }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    func initCells() {
        settingsTable.setRowTypes([ "buttonWithLabel", "switchSetting", "button"])
        
        togglButtonCell = settingsTable.rowController(at: 0) as? ButtonWithLabelViewCell
        togglButtonCell.label.setText("Toggl ID")
        if let togglID = GlobalVar.settings.togglCredential.id {
            togglButtonCell.button.setTitle(togglID)
        }
        else {
            togglButtonCell.button.setTitle("Tap to Sync")
        }
        togglButtonCell.buttonDelegate = self
        
        tickingSoundSwitchCell = settingsTable.rowController(at: 1) as? SwitchSettingViewCell
        tickingSoundSwitchCell.settingValueSwitch.setTitle("Ticking Sound")
        tickingSoundSwitchCell.settingValueSwitch.setOn(GlobalVar.settings.tickingSound)
        tickingSoundSwitchCell.switchSettingDelegate = self
        
        syncButtonCell = settingsTable.rowController(at: 2) as? ButtonViewCell
        syncButtonCell.button.setTitle("Sync Timers")
        syncButtonCell.buttonDelegate = self
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension SettingsViewController: SwitchSettingDelegate {
    func updateSwitchValue(switchSettingViewCell: SwitchSettingViewCell, value: Bool) {
        if switchSettingViewCell == tickingSoundSwitchCell {
            print("Make ticking sound \(value)")
            GlobalVar.settings.tickingSound = value
        }
    }
}

extension SettingsViewController: ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell) {
        GlobalVar.settings.syncTimerList()
    }
}

extension SettingsViewController: ButtonWithLabelDelegate {
    func buttonTapped(buttonWithLabelViewCell: ButtonWithLabelViewCell) {
        print("Requesting Toggl Credential")
        let requestTogglCredential = [WCSessionRequest.request: WCSessionRequest.togglInfo]
        
        if WCSession.default.activationState == .notActivated {
            WCSession.default.sendMessage(requestTogglCredential, replyHandler: { (data) in
                print("Received Toggl Credential")
                let propertyListDecoder = PropertyListDecoder()
                if let data = data[WCSessionRequest.togglInfo] as? Data, let receivedTogglInfo = try? propertyListDecoder.decode(togglInfo.self, from: data) {
                    GlobalVar.settings.receiveTogglInfo(receivedTogglInfo: receivedTogglInfo)
                    if let togglID = GlobalVar.settings.togglCredential.id {
                        self.togglButtonCell.button.setTitle(togglID)
                    }
                    else {
                        self.togglButtonCell.button.setTitle("Tap to Sync")
                    }
                }
            }) { (error) in
                print("WCSession Error")
            }
            let message = "Please make sure iPhone is nearby"
            self.presentAlert(withTitle: "Error", message: message, preferredStyle: .alert, actions: [])
        }
    }
}

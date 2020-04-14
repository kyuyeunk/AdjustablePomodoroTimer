//
//  SettingsViewController.swift
//  
//
//  Created by Kyu Yeun Kim on 2020/04/14.
//

import WatchKit

class SettingsViewController: WKInterfaceController {
    @IBOutlet weak var settingsTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
         super.awake(withContext: context)
     }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    func initCells() {
        settingsTable.setRowTypes([ "switchSetting", "button"])
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

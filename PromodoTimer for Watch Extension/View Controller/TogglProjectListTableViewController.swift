//
//  TogglProjectListTableViewController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TogglProjectListTableViewController: WKInterfaceController {
    @IBOutlet weak var projectTable: WKInterfaceTable!
    override init() {
        super.init()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    func initCells() {
        let projectList = GlobalVar.settings.projectList
        projectTable.setNumberOfRows(projectList.count, withRowType: "projectInfo")
        
        for i in 0 ..< projectList.count {
            let row = projectTable.rowController(at: i) as! ProjectInfoViewCell
            row.projectLabel.setText(projectList[i].name)
        }
    }
}

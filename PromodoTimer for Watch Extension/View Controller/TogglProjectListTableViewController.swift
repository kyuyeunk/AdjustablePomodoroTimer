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
    
    var projectList: [projectInfo]!
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    func initCells() {
        projectList = GlobalVar.settings.projectList
        var rows: [String] = ["button"]
        for _ in 0 ..< projectList.count {
            rows.append("projectInfo")
        }
        projectTable.setRowTypes(rows)
        //projectTable.setNumberOfRows(projectList.count, withRowType: "projectInfo")
        
        let row = projectTable.rowController(at: 0) as! ButtonViewCell
        row.button.setTitle("Save Selection")
        row.buttonDelegate = self
        
        for i in 0 ..< projectList.count {
            let row = projectTable.rowController(at: i + 1) as! ProjectInfoViewCell
            row.projectLabel.setText(projectList[i].name)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        WKInterfaceDevice.current().play(.click)
        print("\(projectList[rowIndex - 1].name) selected")
    }
}

extension TogglProjectListTableViewController: ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell) {
        pop()
    }
}

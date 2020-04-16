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
    
    var timerType: TimerType!
    var workingTimer: TimerModel!
    
    var projectList: [projectInfo]!
    var selectedProjectID: Int?
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        initCells()
    }
    
    override func awake(withContext context: Any?) {
        if let receivedInfo = context as? contextWrapper {
            workingTimer = receivedInfo.timerModel
            timerType = receivedInfo.timerType
        }
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
        
        let prevSelectedProjectID = selectedProjectID
        selectedProjectID = rowIndex - 1
        print("\(projectList[selectedProjectID!].name) selected")
        
        if prevSelectedProjectID != selectedProjectID {
            if prevSelectedProjectID != nil {
                let prevRow = table.rowController(at: prevSelectedProjectID! + 1) as! ProjectInfoViewCell
                prevRow.projectSeparator.setColor(.lightGray)
            }
            let row = table.rowController(at: selectedProjectID! + 1) as! ProjectInfoViewCell
            row.projectSeparator.setColor(.green)
        }
        
    }
}

extension TogglProjectListTableViewController: ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell) {
        if let projectID = selectedProjectID {
            workingTimer.userDefinedTracking[timerType] = trackingInfo(project: projectList[projectID], desc: "")
            pop()
        }
        else {
            print("Project not selected")
        }
    }
}

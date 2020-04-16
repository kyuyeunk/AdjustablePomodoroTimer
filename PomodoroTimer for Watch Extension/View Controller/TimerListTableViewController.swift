//
//  InterfaceController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit
import Foundation


class TimerListTableViewController: WKInterfaceController {
    
    @IBOutlet weak var timerList: WKInterfaceTable!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override init() {
        super.init()
        createObserver()
    }
    
    func createObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeToCurrentPage),
                                               name: changePageNotificationName, object: pageNames.timerListTableView.rawValue)
    }
    
    @objc func changeToCurrentPage() {
        print("Will change to timer table view")
        super.becomeCurrentPage()
    }
    
    func initCells() {
        setTitle("Timer List")
        
        var rowList: [String] = []
        
        for _ in 0 ..< GlobalVar.settings.timerList.count {
            rowList.append("timerInfo")
        }
        rowList.append("button")
        
        timerList.setRowTypes(rowList)
        
        for i in 0 ..< GlobalVar.settings.timerList.count {
            let row = timerList.rowController(at: i) as! TimerInfoViewCell
            
            let timer = GlobalVar.settings.timerList[i]
            row.timerName.setText(timer.timerName)
            let posTime = timer.startTime[.positive]!
            let posMin = posTime / 60
            let posSec = posTime % 60
            
            let negTime = abs(timer.startTime[.negative]!)
            let negMin = negTime / 60
            let negSec = negTime % 60
            
            if i == GlobalVar.settings.currTimerID {
                row.selectedSeparator.setColor(.green)
            }
            else {
                row.selectedSeparator.setColor(.lightGray)
            }
            
            row.posTime.setText("\(posMin)m \(posSec)s")
            row.negTime.setText("\(negMin)m \(negSec)s")
        }
        
        let row = timerList.rowController(at: rowList.count - 1) as! ButtonViewCell
        row.button.setTitle("Add Timer")
        row.buttonDelegate = self
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        WKInterfaceDevice.current().play(.click)
        print("[Timer List] Selected row \(rowIndex)")
        let prevTimerID = GlobalVar.settings.currTimerID
        if rowIndex != prevTimerID {
            print("[Timer List] Selected \(rowIndex) differs from currTimerID \(prevTimerID)")
            var row = timerList.rowController(at: prevTimerID) as! TimerInfoViewCell
            row.selectedSeparator.setColor(.lightGray)
            row = timerList.rowController(at: rowIndex) as! TimerInfoViewCell
            row.selectedSeparator.setColor(.green)
            GlobalVar.settings.currTimerID = rowIndex
        }
        NotificationCenter.default.post(name: resetTimerSettingsViewNotificationName, object: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        initCells()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension TimerListTableViewController: ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell) {
        print("Add Timer Button Tapped")
        //TODO: send info about new timer
        let isNewTimer: [String: Bool] = ["isNewTimer": true]
        NotificationCenter.default.post(name: resetTimerSettingsViewNotificationName, object: nil, userInfo: isNewTimer)
        NotificationCenter.default.post(name: changePageNotificationName, object: pageNames.timerSettingsView.rawValue)
    }
}

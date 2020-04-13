//
//  InterfaceController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit
import Foundation


class TimerTableViewController: WKInterfaceController {
    
    @IBOutlet weak var timerList: WKInterfaceTable!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        timerList.setNumberOfRows(GlobalVar.settings.timerList.count, withRowType: "timerInfo")
        // Configure interface objects here.
        setTitle("Timer List")
    }
    
    func initCells() {
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
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
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

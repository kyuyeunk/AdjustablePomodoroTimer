//
//  TimePickerController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TimePickerController: WKInterfaceController {
    @IBAction func startButtonTapped() {
        if GlobalVar.timeController.timerStarted {
            GlobalVar.timeController.stopButtonTapped()
        }
        else {
            GlobalVar.timeController.startButtonTapped()
        }
    }
    @IBAction func signPicked(_ value: Int) {
        if value == 0 {
            currTime = currMin * 60 + currSec
        }
        else {
            currTime = -(currMin * 60 + currSec)
        }
    }
    @IBAction func minPicked(_ value: Int) {
        currTime = currSign * ((maxMinutes - value) * 60 + currSec)
        print("[Time Picker] set minRow to \(value), currTime is \(currTime)")
        
    }
    @IBAction func secPicked(_ value: Int) {
        currTime = currSign * (currMin * 60 + (59 - value))
        print("[Time Picker] set secRow to \(value), currTime is \(currTime)")
    }
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var secPicker: WKInterfacePicker!
    @IBOutlet weak var signPicker: WKInterfacePicker!
    @IBOutlet weak var minPicker: WKInterfacePicker!
    
    var maxMinutes: Int
    var currTimer: TimerModel = GlobalVar.settings.currTimer
    var currSign: Int {
        if currTime == 0 {
            return 1
        }
        else {
            return currTime / abs(currTime)
        }
    }
    var currMin: Int { currTime / 60}
    var currSec: Int { currTime % 60 }
    
    var currTime: Int
    
    override init() {
        maxMinutes = currTimer.maxMinutes
        currTime = currTimer.startTime[.positive]!
        super.init()
        
        GlobalVar.timeController.timeControllerDelegate = self
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let plus = WKPickerItem()
        plus.title = "+"
        let minus = WKPickerItem()
        minus.title = "-"
        signPicker.setItems([plus, minus])
        
        var minItem: [WKPickerItem] = []
        for i in (0 ... maxMinutes).reversed() {
            let temp = WKPickerItem()
            temp.title = String(i)
            minItem.append(temp)
        }
        minPicker.setItems(minItem)
        minPicker.setSelectedItemIndex(maxMinutes)
        
        var secItem: [WKPickerItem] = []
        for i in (0 ..< 60).reversed() {
            let temp = WKPickerItem()
            temp.title = String(i)
            secItem.append(temp)
        }
        secPicker.setItems(secItem)
        secPicker.setSelectedItemIndex(59)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

extension TimePickerController: TimeControllerDelegate {
    func setSecondUI(currTime: Int, passedTime: [TimerType : Double], animated: Bool, completion: (() -> ())?) {
        
        self.currTime = currTime
        
        print("[Time Picker] setSeconds time: \(currTime) sign: \(self.currSign) min: \(self.currMin) sec: \(self.currSec)")
        
        if self.currSign == -1 {
            signPicker.setSelectedItemIndex(1)
        }
        else {
            signPicker.setSelectedItemIndex(0)
        }
        
        minPicker.setSelectedItemIndex(maxMinutes - self.currMin)
        secPicker.setSelectedItemIndex(59 - self.currSec)
    }
    
    func getCurrTime() -> Int {
        print("[Time Picker] getCurrTime time: \(currTime) sign: \(currSign) min: \(currMin) sec: \(currSec)")
        return currTime
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start")
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop")
    }
    
    func displayTimeoutAlert(type: TimerType, completion: @escaping ((Bool) -> Void)) {
        completion(false)
    }
    
    
}

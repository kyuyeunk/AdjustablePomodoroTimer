//
//  TimePickerController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit
import SpriteKit

class TimePickerController: WKInterfaceController {
    @IBAction func startButtonTapped() {
        print("Deactivate Circle from startButton")
        if GlobalVar.timeController.timerStarted {
            GlobalVar.timeController.stopButtonTapped()
        }
        else {
            GlobalVar.timeController.startButtonTapped()
        }
    }
    var prevSignValue: Int = 0
    @IBAction func signPicked(_ value: Int) {
        let prevCurrTime = currTime
        if value == 0 {
            currTime = currMin * 60 + currSec
        }
        else {
            currTime = -(currMin * 60 + currSec)
        }
        print("[Time Picker] set signRow to \(value), currTime is \(currTime)")
        if prevSignValue != value || prevCurrTime != currTime {
            prevSignValue = value
            print("[Time Picker] currTime changed from \(prevCurrTime) to \(currTime), updating it")
            setTime(currTime: currTime)
        }
    }
    @IBAction func minPicked(_ value: Int) {
        let prevCurrTime = currTime
        currTime = currSign * ((maxMinutes - value) * 60 + currSec)
        print("[Time Picker] set minRow to \(value), currTime is \(currTime)")
        if prevCurrTime != currTime {
            print("[Time Picker] currTime changed from \(prevCurrTime) to \(currTime), updating it")
            setTime(currTime: currTime)
        }
    }
    @IBAction func secPicked(_ value: Int) {
        let prevCurrTime = currTime
        currTime = currSign * (currMin * 60 + (59 - value))
        print("[Time Picker] set secRow to \(value), currTime is \(currTime)")
        if prevCurrTime != currTime {
            print("[Time Picker] currTime changed from \(prevCurrTime) to \(currTime), updating it")
            setTime(currTime: currTime)
        }
    }
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var secPicker: WKInterfacePicker!
    @IBOutlet weak var signPicker: WKInterfacePicker!
    @IBOutlet weak var minPicker: WKInterfacePicker!
    @IBOutlet weak var circleScene: WKInterfaceSKScene!
    
    @IBAction func circleTapped(_ sender: Any) {
        print("Activate Circle")
        timePieView.isHighlighted = true
        timePieView.draw()
        crownSequencer.focus()
    }

    var circleSelected: Bool = false
    var maxMinutes: Int = 0
    var currTimer: TimerModel = GlobalVar.settings.currTimer
    var currSign: Int = 0
    var currMin: Int = 0
    var currSec: Int = 0
    var currTime: Int = 0
    var timePieView: TimePieView!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
 
        maxMinutes = currTimer.maxMinutes
        currTime = currTimer.startTime[.positive]!
        GlobalVar.timeController.timeControllerDelegate = self
        crownSequencer.delegate = self
        crownSequencer.isHapticFeedbackEnabled = true
        
        
        initPicker()
        
        timePieView = TimePieView(maxMinute: maxMinutes, time: currTime)
        circleScene.presentScene(timePieView.circleSKScene)
        timePieView.setTime(time: currTime)
        
        setTime(currTime: currTime)
    }
    
    func initPicker() {
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
        
        var secItem: [WKPickerItem] = []
        for i in (0 ..< 60).reversed() {
            let temp = WKPickerItem()
            temp.title = String(i)
            secItem.append(temp)
        }
        secPicker.setItems(secItem)
    }
    
    func setTime(currTime: Int) {
        self.currTime = currTime
        
        currMin = abs(currTime) / 60
        if abs(currMin) >= maxMinutes {
            self.currTime = maxMinutes * 60
            currSec = 0
        }
        else {
            currSec = abs(currTime) % 60
        }
        
        if currTime >= 0 {
            currSign = 1
        }
        else {
            currSign = -1
        }
        
        if currSign == 1 {
            signPicker.setSelectedItemIndex(0)
        }
        else {
            signPicker.setSelectedItemIndex(1)
        }
        minPicker.setSelectedItemIndex(maxMinutes - currMin)
        secPicker.setSelectedItemIndex(59 - currSec)
        print("[Time Picker] setSeconds time: \(self.currTime) sign: \(self.currSign) min: \(self.currMin) sec: \(self.currSec)")
        print("Drawing circle")
        timePieView.setTime(time: self.currTime)
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
        print("setSecondUI called with \(currTime)")
        setTime(currTime: currTime)

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

extension TimePickerController: WKCrownDelegate {
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        let angle = timePieView.getCurrAngle()
        let newAngle = angle - CGFloat(rotationalDelta)
        let newTime = timePieView.getTime(angle: newAngle)
        print("new angle: \(newAngle) new time: \(newTime)")
        setTime(currTime: newTime)
        print("rotated \(rotationalDelta)")
    }
}

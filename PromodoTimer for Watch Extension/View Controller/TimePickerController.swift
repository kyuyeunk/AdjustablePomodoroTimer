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
    let circleSKScene = SKScene(size: CGSize(width: 100, height: 100))
    
    var maxMinutes: Int
    var currTimer: TimerModel = GlobalVar.settings.currTimer
    var currSign: Int = 0
    var currMin: Int = 0
    var currSec: Int = 0
    var currTime: Int
    
    override init() {
        maxMinutes = currTimer.maxMinutes
        currTime = currTimer.startTime[.positive]!
        super.init()
        
        GlobalVar.timeController.timeControllerDelegate = self
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        initPicker()
        circleSKScene.scaleMode = .aspectFit
        circleScene.presentScene(circleSKScene)
        drawCircle()
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
        
        setTime(currTime: currTime)
    }
    
    func drawCircle() {
        circleSKScene.removeAllChildren()
        let startAngle: CGFloat = .pi / 2
        let endAngle = startAngle + CGFloat(currTime) / CGFloat(maxMinutes * 60) * CGFloat.pi * 2
        var clockwise: Bool
        var color: UIColor
        if currTime >= 0 {
            clockwise = true
            color = .red
        }
        else {
            clockwise = false
            color = .blue
        }
        
        print("[Draw Circle] startAngle: \(startAngle) endAngle: \(endAngle) clockwise: \(clockwise)")
        let path = UIBezierPath()
        let center: CGPoint = .zero
        path.move(to: center)
        path.addArc(withCenter: center, radius: 42, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        path.close()
        color.setFill()
        path.fill()
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = color
        shapeNode.strokeColor = color
        shapeNode.position = CGPoint(x: circleSKScene.size.width / 2, y: circleSKScene.size.height / 2)
        circleSKScene.backgroundColor = .black
        circleSKScene.addChild(shapeNode)
    }
    
    func setTime(currTime: Int) {
        self.currTime = currTime
        
        currMin = abs(currTime) / 60
        if abs(currMin) >= maxMinutes {
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
        print("[Time Picker] setSeconds time: \(currTime) sign: \(self.currSign) min: \(self.currMin) sec: \(self.currSec)")
        print("Drawing circle")
        drawCircle()
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

//
//  TimeController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

protocol TimeControllerDelegate {
    func setSecondUI(currTime: Int)
    func getCurrTime() -> Int
    func stopTimerUI()
    func startTimerUI()
}

class TimeController {
    var toggl = TogglController()
    var timeControllerDelegate: TimeControllerDelegate! {
        didSet {
            print("Changed timeControllerDelegate value")
            if timerStart == true {
                timeControllerDelegate.startTimerUI()
            }
            else {
                timeControllerDelegate.stopTimerUI()
            }
            timeControllerDelegate.setSecondUI(currTime: currTime)
        }
    }
    
    var currTime = 0
    var timer: Timer!
    var timerStart = false {
        didSet {
            if timerStart == true {
                if timeControllerDelegate.getCurrTime() == 0 {
                    print("Start button pressed when selected time is 0")
                    timerStart = false
                }
                else {
                    startTimer()
                }
            }
            else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timeControllerDelegate.stopTimerUI()
        if timer.isValid {
            timer.invalidate()
            toggl.stopTimer()
        }
    }
    
    func startTimer() {
        toggl.startTimer(pid: 89341778, desc: "Testing")        //TODO: Testing purpose. Should be user-definable
        timeControllerDelegate.startTimerUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            var currTime = self.timeControllerDelegate.getCurrTime()
 
            if currTime > 0 {
                currTime -= 1
            }
            else if currTime < 0 {
                currTime += 1
            }
            else {
                print("ERROR: timer should have ended before reaching 0")
                return
            }
            
            print("seconds: \(currTime)")
            self.timeControllerDelegate.setSecondUI(currTime: currTime)
            
            if currTime == 0 {
                 print("Reached 0 seconds")
                 self.timerStart = false
            } else {
                self.currTime = currTime
            }
        })
    }
}

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
        let startTime = self.timeControllerDelegate.getCurrTime()
        if startTime > 0 {
            toggl.startTimer(type: .positive)        //TODO: Testing purpose. Should be user-definable
        }
        else {
            toggl.startTimer(type: .negative)
        }
        
        timeControllerDelegate.startTimerUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            var newTime = self.timeControllerDelegate.getCurrTime()
            if (self.currTime > 0 && newTime < 0) {
                print("[Timer] changed from positive to negative")
                self.toggl.stopTimer()
                self.toggl.startTimer(type: .negative)
            }
            else if (self.currTime < 0 && newTime > 0) {
                print("[Timer] changed from negative to positive")
                self.toggl.stopTimer()
                self.toggl.startTimer(type: .positive)
            }
 
            if newTime > 0 {
                newTime -= 1
            }
            else if newTime < 0 {
                newTime += 1
            }
            else {
                print("ERROR: timer should have ended before reaching 0")
                return
            }
            
            print("[Timer]: current seconds: \(newTime)")
            self.timeControllerDelegate.setSecondUI(currTime: newTime)
            
            if newTime == 0 {
                 print("[Timer] Reached 0 seconds")
                 self.timerStart = false
            } else {
                self.currTime = newTime
            }
        })
    }
}

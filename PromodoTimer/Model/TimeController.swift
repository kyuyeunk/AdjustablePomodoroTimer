//
//  TimeController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

//Allow view controllers to change UI when timer event triggers
//Allow TimeController to fetch current time from view controllers
protocol TimeControllerDelegate {
    func setSecondUI(currTime: Int)
    func getCurrTime() -> Int
    func stopTimerUI()
    func startTimerUI()
}

class TimeController {
    var toggl = TogglController()
    var timeControllerDelegate: TimeControllerDelegate! {
        //If the view has been changed, change the UI accordingly
        //E.g., change clock hand if timer's current time doesn't match the clock hand
        didSet {
            print("[Timer] Changed timeControllerDelegate value")
            if timerStart == true {
                timeControllerDelegate.startTimerUI()
            }
            else {
                timeControllerDelegate.stopTimerUI()
            }
            timeControllerDelegate.setSecondUI(currTime: prevTime)
        }
    }
    
    var prevTime = 0
    var timer: Timer!
    var timerStart = false {
        didSet {
            if timerStart == true {
                if timeControllerDelegate.getCurrTime() == 0 {
                    print("[Timer] Start button pressed when selected time is 0")
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
        prevTime = 0
        timeControllerDelegate.stopTimerUI()
        if timer.isValid {
            timer.invalidate()
            toggl.stopTimer()
        }
    }
    
    func startTimer() {
        //Based on the current time, positive or negative toggl timer should be started
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
            if (self.prevTime > 0 && newTime < 0) {
                print("[Timer] changed from positive to negative")
                self.toggl.stopTimer()
                self.toggl.startTimer(type: .negative)
            }
            else if (self.prevTime < 0 && newTime > 0) {
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
            
            print("[Timer] current seconds: \(newTime)")
            self.timeControllerDelegate.setSecondUI(currTime: newTime)
            
            self.prevTime = newTime
            if newTime == 0 {
                 print("[Timer] Reached 0 seconds")
                 self.timerStart = false
            }
        })
    }
}

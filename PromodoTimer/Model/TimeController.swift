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
    func setSecondUI(currTime: Int, animated: Bool, completion: (() -> ())?)
    func getCurrTime() -> Int
    func stopTimerUI()
    func startTimerUI()
    func togglStartTimerUI(type: TrackingType)
    func togglStopTimerUI(type: TrackingType)
}

class TimeController {
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
                prevTime = GlobalVar.settings.timerList[GlobalVar.settings.currTimer].posStartTime
            }
            timeControllerDelegate.setSecondUI(currTime: prevTime, animated: false, completion: nil)
        }
    }
    
    var currType: TrackingType = .positive
    var prevTime = GlobalVar.settings.currPostStartTime
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
        timeControllerDelegate.stopTimerUI()
        if timer.isValid {
            timer.invalidate()
            
            let prevType = currType
            GlobalVar.toggl.stopTimer() { (complete: Bool) in
                self.timeControllerDelegate.togglStopTimerUI(type: prevType)
            }
            
            //If prevTime is 0, assume timer stopped automatically
            if prevTime == 0 && GlobalVar.settings.currAutoRepeat {
                print("[Timer] Setting up next auto timer")
                var nextTimerTime: Int
                if currType == .positive {
                    print("[Timer] Started as a Positive Timer")
                    nextTimerTime = GlobalVar.settings.currNegStartTime
                    
                }
                else {
                    print("[Timer] Started as a Negative Timer")
                    nextTimerTime = GlobalVar.settings.currPostStartTime
                }
                
                timeControllerDelegate.setSecondUI(currTime: nextTimerTime, animated: true) { () in
                    self.timerStart = true
                }
            }
            
        }
    }
    
    func startTimer() {
        //Based on the current time, positive or negative toggl timer should be started
        let startTime = self.timeControllerDelegate.getCurrTime()
        if startTime > 0 {
            currType = .positive
        }
        else {
            currType = .negative
        }
        
        GlobalVar.toggl.startTimer(type: currType) { (complete: Bool) in
            self.timeControllerDelegate.togglStartTimerUI(type: self.currType)
        }
        
        timeControllerDelegate.startTimerUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            var newTime = self.timeControllerDelegate.getCurrTime()
            if (self.prevTime > 0 && newTime < 0) {
                print("[Timer] changed from positive to negative")
                GlobalVar.toggl.stopTimer() { (complete: Bool) in
                    self.timeControllerDelegate.togglStopTimerUI(type: .positive)
                }
                self.currType = .negative
                GlobalVar.toggl.startTimer(type: .negative) { (complete: Bool) in
                    print("Negative Toggl Started")
                }
            }
            else if (self.prevTime < 0 && newTime > 0) {
                print("[Timer] changed from negative to positive")
                GlobalVar.toggl.stopTimer() { (complete: Bool) in
                    self.timeControllerDelegate.togglStopTimerUI(type: .negative)
                }
                self.currType = .positive
                GlobalVar.toggl.startTimer(type: .positive) { (complete: Bool) in
                    print("Positive Toggl Started")
                }
            }
            
            if newTime > 0 {
                newTime -= 1
            }
            else if newTime < 0 {
                newTime += 1
            }
            else {
                print("[Timer] Reached 0 seconds")
                self.timerStart = false
                return
            }
            
            print("[Timer] current seconds: \(newTime)")
            self.prevTime = newTime
            self.timeControllerDelegate.setSecondUI(currTime: newTime, animated: true, completion: nil)
        })
    }
}

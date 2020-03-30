//
//  TimeController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


//Allow view controllers to change UI when timer event triggers
//Allow TimeController to fetch current time from view controllers
protocol TimeControllerDelegate {
    func setSecondUI(currTime: Int, passedTime: [TimerType: Double], animated: Bool, completion: (() -> ())?)
    func getCurrTime() -> Int
    func stopTimerUI()
    func startTimerUI()
    func togglStartTimerUI(type: TimerType)
    func togglStopTimerUI(type: TimerType)
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
                prevTime = GlobalVar.settings.currPosStartTime
            }
            timeControllerDelegate.setSecondUI(currTime: prevTime, passedTime: passedTime, animated: false, completion: nil)
        }
    }
    
    var currType: TimerType = .positive
    var prevTime = GlobalVar.settings.currPosStartTime
    var passedTime: [TimerType: Double] = [.positive: 0, .negative: 0]
    var startedTime: [TimerType: TimeInterval] = [.positive: Date().timeIntervalSince1970, .negative: Date().timeIntervalSince1970]
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
            
            GlobalVar.toggl.stopTimer()
            
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
                    nextTimerTime = GlobalVar.settings.currPosStartTime
                }
                
                timeControllerDelegate.setSecondUI(currTime: nextTimerTime, passedTime: passedTime, animated: true) { () in
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
        
        startedTime[currType] = Date().timeIntervalSince1970
        
        GlobalVar.toggl.startTimer(type: currType)
        
        timeControllerDelegate.startTimerUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            var newTime = self.timeControllerDelegate.getCurrTime()
            if (self.prevTime > 0 && newTime < 0) {
                self.prevTime = newTime
                print("[Timer] changed from positive to negative")
                GlobalVar.toggl.stopTimer()
                self.currType = .negative
                GlobalVar.toggl.startTimer(type: .negative)
                return
            }
            else if (self.prevTime < 0 && newTime > 0) {
                self.prevTime = newTime
                print("[Timer] changed from negative to positive")
                GlobalVar.toggl.stopTimer()
                self.currType = .positive
                GlobalVar.toggl.startTimer(type: .positive)
                return
            }
            
            
            if newTime > 0 {
                newTime -= 1
                
            }
            else if newTime < 0 {
                newTime += 1
            }
            
            print("[Timer] current seconds: \(newTime)")
            self.prevTime = newTime
            
            let currTimeSince1970 = Date().timeIntervalSince1970
            self.passedTime[self.currType]! += Double(currTimeSince1970 - self.startedTime[self.currType]!)
            self.startedTime[self.currType]! = currTimeSince1970
            
            self.timeControllerDelegate.setSecondUI(currTime: newTime, passedTime: self.passedTime, animated: true) { () in
                if newTime == 0 {
                    print("[Timer] Reached 0 seconds")
                    AudioServicesPlayAlertSound(SystemSoundID(1005))
                    self.timerStart = false
                }
            }
            

        })
    }
    
    func startButtonTapped() {
        timerStart = true
        
        if !GlobalVar.settings.currAccumulatePassedTime {
            self.passedTime[.positive] = 0
            self.passedTime[.negative] = 0
        }
    }
    
    func stopButtonTapped() {
        timerStart = false
    }
}

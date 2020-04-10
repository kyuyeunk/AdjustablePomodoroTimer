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
    func displayTimeoutAlert(type: TimerType, completion: @escaping ((Bool) -> Void))
}

class TimeController {
    var timeControllerDelegate: TimeControllerDelegate!
    
    let uuidString = UUID().uuidString
    var currType: TimerType = .positive
    var prevTime = GlobalVar.settings.currTimer.startTime[.positive]!
    var passedTime: [TimerType: Double] = [.positive: 0, .negative: 0]
    var startedTime: [TimerType: TimeInterval] = [.positive: Date().timeIntervalSince1970, .negative: Date().timeIntervalSince1970]
    var timer = Timer()
    var timerStarted: Bool {
        return timer.isValid
    }
    
    func stopTimer(autoRepeat: Bool) {
        if timer.isValid {
            timer.invalidate()
        }
        
        GlobalVar.toggl.stopTimer()
        
        print("[Timer] Setting up next auto timer")
        var nextTimerTime: Int
        if currType == .positive {
            print("[Timer] Started as a Positive Timer")
            nextTimerTime = GlobalVar.settings.currTimer.startTime[.negative]!
        }
        else {
            print("[Timer] Started as a Negative Timer")
            nextTimerTime = GlobalVar.settings.currTimer.startTime[.positive]!
        }
        
        if autoRepeat {
            timeControllerDelegate.setSecondUI(currTime: nextTimerTime, passedTime: passedTime, animated: true) { () in
                //As startTimer() fetches current time from UI,
                //startTimer() should start after the UI function finishes
                self.startTimer()
            }
        }
        else {
            if prevTime == 0 {
                timeControllerDelegate.setSecondUI(currTime: nextTimerTime, passedTime: passedTime, animated: true, completion: nil)
            }
            timeControllerDelegate.stopTimerUI()
        }
    }
    
    func startTimer() {
        //Always assume that starting time is set by UI
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
        
        startScheduledTimer()
    }
    
    func startScheduledTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            //New time should always be fetched from the UI
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
            
            self.createNotification(delayTime: abs(newTime))
            
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
            self.startedTime[.positive]! = currTimeSince1970
            self.startedTime[.negative]! = currTimeSince1970
            
            self.timeControllerDelegate.setSecondUI(currTime: newTime, passedTime: self.passedTime, animated: true, completion: nil)
            if GlobalVar.settings.tickingSound {
                AudioServicesPlaySystemSound(SystemSoundID(1104))
            }
            
            if newTime == 0 {
                print("[Timer] Reached 0 seconds, starting the alarm")
                
                if GlobalVar.settings.currTimer.alertTimerEnd {
                    print("[Timer] Reached 0 seconds, starting the alert")
                    self.timeControllerDelegate.displayTimeoutAlert(type: self.currType, completion: { (autoRepeat: Bool) in
                        print("[Timer] Did user decided to continue the timer?: \(autoRepeat)")
                        self.stopTimer(autoRepeat: autoRepeat)
                    })
                }
                else {
                    let systemAlarmID = GlobalVar.alarmSounds.list[GlobalVar.settings.currTimer.timerAlarmID[self.currType]!].systemSoundID
                    AudioServicesPlaySystemSound(SystemSoundID(systemAlarmID))
                    let autoRepeat = GlobalVar.settings.currTimer.autoRepeat
                    print("[Timer] Stop the timer with auto repeat? \(autoRepeat)")
                    self.stopTimer(autoRepeat: autoRepeat)
                }
                timer.invalidate()
                print("[Timer] Stopping the timer")
            }
        })
    }
    
    func startButtonTapped() {
        if timeControllerDelegate.getCurrTime() == 0 {
            print("[Timer] Start button pressed when selected time is 0")
        }
        else {
            if !GlobalVar.settings.currTimer.accumulatePassedTime {
                self.passedTime[.positive] = 0
                self.passedTime[.negative] = 0
            }
            
            startTimer()
        }
    }
    
    func stopButtonTapped() {
        stopTimer(autoRepeat: false)
        print("[Timer] Stopping notification")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:[uuidString])
    }
    
    func createNotification(delayTime: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:[uuidString])
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        if delayTime > 0 {
            content.body = "Your positive timer has ended"
        }
        else {
            content.body = "Your negative timer has ended"
        }
        content.sound = UNNotificationSound.default

        print("[Timer] Notification will start in \(delayTime)")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(abs(delayTime)), repeats: false)
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
    
        UNUserNotificationCenter.current().add(request) { (error) in
            //TODO
        }
    }
}

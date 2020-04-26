//
//  TimeController.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchConnectivity
import UserNotifications
#if os(iOS)
import UIKit
import AudioToolbox
import AVFoundation
#elseif os(watchOS)
import WatchKit
#endif

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
    
    private let uuidString = UUID().uuidString
    private var currType: TimerType = .positive
    private var prevTime = GlobalVar.settings.currTimer.startTime[.positive]!
    private var passedTime: [TimerType: Double] = [.positive: 0, .negative: 0]
    private var startedTime: [TimerType: TimeInterval] = [.positive: Date().timeIntervalSince1970, .negative: Date().timeIntervalSince1970]
    private var timer = Timer()
    
    var timerStarted: Bool {
        return timer.isValid
    }
    
    private func stopTimer(autoRepeat: Bool) {
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
            sendStopTimer()
        }
    }
    
    private func startTimer() {
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
        sendStartTimer()
    }
    
    private func startScheduledTimer() {
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
            
            self.createNotification(delayTime: newTime)
            
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
                #if os(iOS)
                AudioServicesPlaySystemSound(SystemSoundID(1104))
                #elseif os(watchOS)
                WKInterfaceDevice.current().play(.click)
                #endif
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
                    #if os(iOS)
                    let systemAlarmID = GlobalVar.alarmSounds.list[GlobalVar.settings.currTimer.timerAlarmID[self.currType]!].systemSoundID
                    AudioServicesPlaySystemSound(SystemSoundID(systemAlarmID))
                    #elseif os(watchOS)
                    //TODO: fix bug where sound wouldn't play
                    if self.currType == .positive {
                        WKInterfaceDevice.current().play(.success)
                    }
                    else {
                        WKInterfaceDevice.current().play(.failure)
                    }
                    #endif
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
    
    private func createNotification(delayTime: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:[uuidString])
        let content = UNMutableNotificationContent()
        content.title = "Timer Ended"
        if delayTime > 0 {
            content.body = "Positive timer ended"
        }
        else {
            content.body = "Negative timer ended"
        }
        content.sound = UNNotificationSound.default

        print("[Timer] Notification will start in \(delayTime)")
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(abs(delayTime)), repeats: false)
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            //TODO
        }
    }
    
    private func sendStartTimer() {
        print("Sending start timer")
        let message = [WCSessionMessageType.startTimer: self.prevTime]
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    private func sendStopTimer() {
        print("Sending stop timer")
        let message = [WCSessionMessageType.stopTimer: true]
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    func receiveStartTimer(time: Int) {
        print("Received start timer with start time \(time)")
        timeControllerDelegate.setSecondUI(currTime: time, passedTime: passedTime, animated: true) {
            if self.timerStarted {
                self.startTimer()
            }
        }
    }
}

//
//  TimeController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

protocol TimeControllerDelegate {
    func passSecondUI(currTime: Int)
    func getCurrTime() -> Int
    func stopTimerUI()
    func startTimerUI()
}

class TimeController {
    var toggl = TogglController()
    var timeControllerDelegate: TimeControllerDelegate
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
    
    init(delegate: TimeControllerDelegate) {
        timeControllerDelegate = delegate
    }
    
    func stopTimer() {
        timeControllerDelegate.stopTimerUI()
        timer.invalidate()
    }
    
    func startTimer() {
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
            self.timeControllerDelegate.passSecondUI(currTime: currTime)
            
            if currTime == 0 {
                 print("Reached 0 seconds")
                 self.timerStart = false
             }
        })
    }
}

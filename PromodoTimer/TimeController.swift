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
    init(delegate: TimeControllerDelegate) {
        timeControllerDelegate = delegate
    }
    
    var timeControllerDelegate: TimeControllerDelegate
    var timer: Timer!
    var timerStart = false {
        willSet(newVal) {
            if newVal == true {
                startTimer()
            }
            else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timeControllerDelegate.stopTimerUI()
        timer.invalidate()
    }
    
    func startTimer() {
        timeControllerDelegate.startTimerUI()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            var currTime = self.timeControllerDelegate.getCurrTime()
            if currTime == 0 {
                print("Reached 0 seconds")
                self.timerStart = false
                return
            }
            else if currTime > 0 {
                currTime -= 1
            }
            else {
                currTime += 1
            }
            
            print("seconds: \(currTime)")
            self.timeControllerDelegate.passSecondUI(currTime: currTime)
            
            
        })
    }
}

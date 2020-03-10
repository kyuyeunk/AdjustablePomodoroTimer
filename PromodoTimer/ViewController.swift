//
//  ViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timer: Timer!
    var seconds: [Int] = []
    var timerStart = false {
        willSet(newVal) {
            if newVal == true {
                startTimer()
                startButton.setTitle("Stop", for: .normal)
            }
            else {
                stopTimer()
                startButton.setTitle("Start", for: .normal)
            }
        }
    }
    @IBOutlet weak var mainTimer: UIPickerView!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        if timerStart == false {
            print("Pressed Start Button")
            timerStart = true
        }
        else {
            print("Pressed Stop Button")
            timerStart = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initButtons()
        // Do any additional setup after loading the view.
    }

    
    func initButtons() {
        startButton.setTitle("Start", for: .normal)
        for i in (-60 ... 60).reversed() {
            seconds.append(i)
        }
        
        mainTimer.dataSource = self
        mainTimer.delegate = self
        
        mainTimer.selectRow(60, inComponent: 0, animated: false)
    }

    func stopTimer() {
        timer.invalidate()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func startTimer() {
        let selectedRow = mainTimer.selectedRow(inComponent: 0)
        let selectedTime: Int = seconds[selectedRow]
        print("Starting time is \(selectedTime)")
                
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
            var currRow = self.mainTimer.selectedRow(inComponent: 0)
            if currRow > 60 {
                currRow -= 1
            }
            else {
                currRow += 1
            }
            
            print("seconds: \(self.seconds[currRow]), row: \(currRow)")
            DispatchQueue.main.async {
                self.mainTimer.selectRow(currRow, inComponent: 0, animated: true)
            }
            if self.seconds[currRow] == 0 {
                print("Reached 0 seconds")
                self.timerStart = false
            }
        })
    }
    
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seconds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(seconds[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if timerStart {
            print("Moved timer during timing")
        }
    }
}

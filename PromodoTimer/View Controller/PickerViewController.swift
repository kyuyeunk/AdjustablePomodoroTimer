//
//  ViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    var timer: TimeController!
    var secondRows: [Int] = []

    @IBOutlet weak var mainTimer: UIPickerView!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        if timer.timerStart == false {
            print("Pressed Start Button")
            timer.timerStart = true
        }
        else {
            print("Pressed Stop Button")
            timer.timerStart = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        timer = TimeController(delegate: self)
        // Do any additional setup after loading the view.
    }

    
    func initUI() {
        startButton.setTitle("Start", for: .normal)
        for i in (-60 ... 60).reversed() {
            secondRows.append(i)
        }
        
        mainTimer.dataSource = self
        mainTimer.delegate = self
        
        mainTimer.selectRow(60, inComponent: 0, animated: false)
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return secondRows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(secondRows[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if timer.timerStart {
            print("Moved timer during timing")
        }
    }
}

extension PickerViewController: TimeControllerDelegate {
    func passSecondUI(currTime: Int) {
        DispatchQueue.main.async {
            self.mainTimer.selectRow(60 - currTime, inComponent: 0, animated: true)
        }
    }
    
    func getCurrTime() -> Int {
        return 60 - mainTimer.selectedRow(inComponent: 0)
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
    }
}

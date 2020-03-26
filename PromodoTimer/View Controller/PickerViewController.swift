//
//  ViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    var posSecondRows: [Int] = []
    var negSecondRows: [Int] = []
    var secondRows: [Int] = []
    let MAX_ROW: Int = Int(INT16_MAX)
    var MIDDLE_ROW: Int {
        return MAX_ROW / 2
    }

    @IBOutlet weak var posTimeLabel: UILabel!
    @IBOutlet weak var negTimeLabel: UILabel!
    @IBOutlet weak var mainTimer: UIPickerView!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        if GlobalVar.timeController.timerStart == false {
            print("Pressed Start Button")
            GlobalVar.timeController.timerStart = true
        }
        else {
            print("Pressed Stop Button")
            GlobalVar.timeController.timerStart = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalVar.timeController.timeControllerDelegate = self
    }
    
    func initUI() {
        startButton.setTitle("Start", for: .normal)
        posTimeLabel.text = "Off"
        negTimeLabel.text = "Off"
        for i in (0 ... 59).reversed() {
            posSecondRows.append(i)
        }
        for i in (-59 ... 0).reversed() {
            negSecondRows.append(i)
        }
        for i in (-59 ... 59).reversed() {
            secondRows.append(i)
        }
        
        mainTimer.dataSource = self
        mainTimer.delegate = self
        
        mainTimer.selectRow(MIDDLE_ROW, inComponent: 0, animated: false)
        mainTimer.selectRow(MIDDLE_ROW, inComponent: 1, animated: false)
    }
}

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MAX_ROW
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currSeconds = (MIDDLE_ROW - row) % 60
        let currSecondsStr: String
        if currSeconds == 0 && row > MIDDLE_ROW {
            currSecondsStr = "-0"
        }
        else {
            currSecondsStr = String(currSeconds)
        }
        return currSecondsStr
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if GlobalVar.timeController.timerStart {
            print("Moved timer during timing")
        }
    }
}

extension PickerViewController: TimeControllerDelegate {
    func togglStartTimerUI(type: TimerType) {
        DispatchQueue.main.async {
            if type == .positive {
                self.posTimeLabel.textColor = .red
            }
            else {
                self.negTimeLabel.textColor = .red
            }
        }
    }
    
    func togglStopTimerUI(type: TimerType) {
        DispatchQueue.main.async {
            if type == .positive {
                self.posTimeLabel.textColor = .white
            }
            else {
                self.negTimeLabel.textColor = .white
            }
        }
    }
    
    func setSecondUI(currTime: Int, togglTime: [TimerType: Int], animated: Bool, completion: (() -> ())?) {
        DispatchQueue.main.async {
            self.mainTimer.selectRow(60 - currTime, inComponent: 0, animated: animated)
            self.posTimeLabel.text = String(togglTime[.positive]!)
            self.negTimeLabel.text = String(togglTime[.negative]!)
            if let completion = completion {
                completion()
            }
        }
    }
    
    func getCurrTime() -> Int {
        let row = mainTimer.selectedRow(inComponent: 0)
        print("[Picker View] selectedRow: \(row) seconds: \(60 - row)")
        return 60 - mainTimer.selectedRow(inComponent: 0)
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
    }
}

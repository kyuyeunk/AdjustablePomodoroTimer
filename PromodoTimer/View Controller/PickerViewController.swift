//
//  ViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

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
            GlobalVar.timeController.startButtonTapped()
        }
        else {
            print("Pressed Stop Button")
            GlobalVar.timeController.stopButtonTapped()
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
        if component == 1 {
            let seconds = (MIDDLE_ROW - row) % 60
            let minutes = (MIDDLE_ROW - row) / 60
            let minSub = abs(minutes).toSuperscript()
            
            if (MIDDLE_ROW - row) < 0 && seconds == 0 {
                return "-0 \(minSub)"
            }
            else {
                return "\(seconds) \(minSub)"
            }
        }
        else {
            return String(MIDDLE_ROW - row)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            print("[Picker View] Minute picker moved")
            let minutes = MIDDLE_ROW - row
            let seconds = (MIDDLE_ROW - pickerView.selectedRow(inComponent: 1)) % 60
            var time: Int
            if minutes > 0 && seconds < 0 {
                time = (minutes + 1) * 60 - seconds
            }
            else if minutes < 0 && seconds > 0 {
                time = minutes  * 60 - seconds
            }
            else {
                time = minutes * 60 + seconds
            }

            print("[Picker View] Selected val in Min: \(minutes), in Sec: \(time)")
            pickerView.selectRow(MIDDLE_ROW - time, inComponent: 1, animated: false)
        }
        else {
            print("[Picker View] Second picker moved")
            let time = MIDDLE_ROW - row
            let minutes = time / 60
            
            print("[Picker View] Selected val in Min: \(minutes), in Sec: \(time)")
            pickerView.selectRow(MIDDLE_ROW - minutes, inComponent: 0, animated: true)
        }
        if GlobalVar.timeController.timerStart {
            print("[Picker View] Moved timer during timing")
        }
    }
}

extension PickerViewController: TimeControllerDelegate {
    func displayTimeoutAlert(completion: @escaping (() -> ())) {
        //TODO: Implement ability to stop the timer when the alert is displayed
        DispatchQueue.main.async {
            var alert: UIAlertController
            var continueButton: UIAlertAction
            var stopButton: UIAlertAction
            
            alert = UIAlertController(title: "Time out",
                                      message: "Your positive timer lasted 123 seconds", preferredStyle: .alert)
            //TODO: do differnt things for continue and stop buttons
            continueButton = UIAlertAction(title: "Ok", style: .default, handler: {(UIAlertAction) in
                completion()
            })
            stopButton = UIAlertAction(title: "Stop", style: .default, handler: {(UIAlertAction) in
                completion()
            })
            
            alert.addAction(continueButton)
            alert.addAction(stopButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
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
    
    func setSecondUI(currTime: Int, passedTime: [TimerType: Double], animated: Bool, completion: (() -> ())?) {
        let posTime = Int(passedTime[.positive]!)
        let negTime = Int(passedTime[.negative]!)
        
        let posSeconds = posTime % 60
        let posMinutes = posTime / 60
        
        let negSeconds = negTime % 60
        let negMinutes = negTime / 60
        
        DispatchQueue.main.async {
            print("[Picker View] Setting timer UI to \(currTime) seconds")
            self.mainTimer.selectRow(self.MIDDLE_ROW - currTime, inComponent: 1, animated: animated)
            self.mainTimer.selectRow((self.MIDDLE_ROW - currTime / 60), inComponent: 0, animated: animated)
            self.posTimeLabel.text = "\(posMinutes)m \(posSeconds)s"
            self.negTimeLabel.text = "\(negMinutes)m \(negSeconds)s"
            if let completion = completion {
                completion()
            }
        }
    }
    
    func getCurrTime() -> Int {
        let row = mainTimer.selectedRow(inComponent: 1)
        print("[Picker View] selectedRow: \(row) seconds: \(MIDDLE_ROW - row)")
        return MIDDLE_ROW - mainTimer.selectedRow(inComponent: 1)
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
    }
}

extension Int {
    func toSuperscript() -> String {
        var j = self
        var ret = ""
        if self >= 10 {
            let i = self / 10
            ret = i.toSuperscript()
            j = self % 10
        }
        
        let uni: Int
        if j == 2 {
            uni = 0x00B2
        }
        else if j == 3 {
            uni = 0x00B3
        }
        else if j == 1 {
            uni = 0x00B9
        }
        else {
            uni = 0x2070 + j
        }
        let scalarValue = UnicodeScalar(uni)!
        let string = String(scalarValue)
        
        return ret + string
    }
}


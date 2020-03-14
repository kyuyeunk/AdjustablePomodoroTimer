//
//  ViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController {

    var secondRows: [Int] = []

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GlobalVar.timeController.timeControllerDelegate = self
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
        if GlobalVar.timeController.timerStart {
            print("Moved timer during timing")
        }
    }
}

extension PickerViewController: TimeControllerDelegate {
    func setSecondUI(currTime: Int) {
        let pickerTime = getCurrTime()
        var animated = false
        if pickerTime + 1 == currTime || pickerTime - 1 == currTime {
            animated = true
        }
 
        print("PickerView currTime: \(currTime)")
        DispatchQueue.main.async {

            
            self.mainTimer.selectRow(60 - currTime, inComponent: 0, animated: animated)
        }
    }
    
    func getCurrTime() -> Int {
        print("Got current time from Picker View")
        return 60 - mainTimer.selectedRow(inComponent: 0)
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
    }
}

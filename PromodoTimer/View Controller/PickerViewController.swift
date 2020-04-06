//
//  ViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class PickerViewController: UIViewController {

    let MAX_ROW: Int = Int(INT16_MAX)
    var MIDDLE_ROW: Int {
        return MAX_ROW / 2
    }

    var passedTimeLabel = UILabel()
    var timeInfoStackView = UIStackView()
    var posInfoStackView = UIStackView()
    var negInfoStackView = UIStackView()
    var pickerInfoStackView = UIStackView()
    
    var posTimeLabel = UILabel()
    var negTimeLabel = UILabel()
    
    var posTimeValLabel = UILabel()
    var negTimeValLabel = UILabel()
    
    var pickerInfoMinutesLabel = UILabel()
    var pickerInfoSecondsLabel = UILabel()
    
    var mainTimer = UIPickerView()
    var startButton = UIButton(type: .system)
    
    @objc func startButtonPressed(_ sender: Any) {
        if GlobalVar.timeController.timerStarted == false {
            print("[Picker View] Pressed Start Button")
            GlobalVar.timeController.startButtonTapped()
        }
        else {
            print("[Picker View] Pressed Stop Button")
            GlobalVar.timeController.stopButtonTapped()
        }
    }
    
    @objc func leftBarPressed() {
        
    }
    
    @objc func rightBarPressed() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
        
        //TODO: let user grant the autorization from settings menu even if user pressed no
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("Did user granted autorization? \(granted)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalVar.timeController.timeControllerDelegate = self
        UIApplication.shared.isIdleTimerDisabled = GlobalVar.settings.dontSleep
        print("[Picker View] Will this view stay on? \(GlobalVar.settings.dontSleep)")
    }
    
    func initUI() {
        addToViews()
        initUIAttributes()
        initUIConstraints()
        initUIFeatures()
    }
    
    func addToViews() {
        view.addSubview(passedTimeLabel)
        view.addSubview(timeInfoStackView)
        view.addSubview(pickerInfoStackView)
        view.addSubview(mainTimer)
        view.addSubview(startButton)
        
        timeInfoStackView.addArrangedSubview(posInfoStackView)
        timeInfoStackView.addArrangedSubview(negInfoStackView)
        
        posInfoStackView.addArrangedSubview(posTimeLabel)
        posInfoStackView.addArrangedSubview(posTimeValLabel)
        
        negInfoStackView.addArrangedSubview(negTimeLabel)
        negInfoStackView.addArrangedSubview(negTimeValLabel)
        
        pickerInfoStackView.addArrangedSubview(pickerInfoMinutesLabel)
        pickerInfoStackView.addArrangedSubview(pickerInfoSecondsLabel)
    }
    
    func initUIAttributes() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(leftBarPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Timers", style: .plain, target: self, action: #selector(rightBarPressed))
        
        passedTimeLabel.text = "Passed Time"
        passedTimeLabel.font = passedTimeLabel.font.withSize(25)
        
        posTimeLabel.text = "Positive:"
        posTimeLabel.textAlignment = .center
        
        negTimeLabel.text = "Negative:"
        negTimeLabel.textAlignment = .center
        
        posTimeValLabel.text = "0m 0s"
        posTimeValLabel.textAlignment = .center
        
        negTimeValLabel.text = "0m 0s"
        negTimeValLabel.textAlignment = .center
        
        pickerInfoMinutesLabel.text = "Minutes"
        pickerInfoMinutesLabel.textAlignment = .center
        
        pickerInfoSecondsLabel.text = "Secondsᵐⁱⁿ"
        pickerInfoSecondsLabel.textAlignment = .center
        
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = startButton.titleLabel?.font.withSize(25)
        
        timeInfoStackView.axis = .horizontal
        timeInfoStackView.distribution = .fillEqually
        timeInfoStackView.spacing = 0
        
        posInfoStackView.axis = .vertical
        posInfoStackView.distribution = .fillEqually
        posInfoStackView.spacing = 5
        
        negInfoStackView.axis = .vertical
        negInfoStackView.distribution = .fillEqually
        negInfoStackView.spacing = 5
        
        pickerInfoStackView.axis = .horizontal
        pickerInfoStackView.distribution = .fillEqually
        pickerInfoStackView.spacing = 0
    }
    
    func initUIConstraints() {
        passedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        passedTimeLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 40).isActive = true
        passedTimeLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0).isActive = true
        
        timeInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        timeInfoStackView.topAnchor.constraint(equalTo: passedTimeLabel.bottomAnchor, constant: 20).isActive = true
        timeInfoStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        timeInfoStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        
        pickerInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        pickerInfoStackView.bottomAnchor.constraint(equalTo: mainTimer.topAnchor, constant: -20).isActive = true
        pickerInfoStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        pickerInfoStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        
        mainTimer.translatesAutoresizingMaskIntoConstraints = false
        mainTimer.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0).isActive = true
        mainTimer.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor, constant: 0).isActive = true
        mainTimer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        mainTimer.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.topAnchor.constraint(equalTo: mainTimer.bottomAnchor, constant: 20).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0).isActive = true
    }
    
    func initUIFeatures() {
        mainTimer.dataSource = self
        mainTimer.delegate = self
        
        mainTimer.selectRow(MIDDLE_ROW, inComponent: 0, animated: false)
        mainTimer.selectRow(MIDDLE_ROW, inComponent: 1, animated: false)
        
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
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
        if GlobalVar.timeController.timerStarted {
            print("[Picker View] Moved timer during timing")
        }
    }
}

extension PickerViewController: TimeControllerDelegate {
    func displayTimeoutAlert(completion: @escaping ((Bool) -> Void)) {

            
        DispatchQueue.main.async {
            var alert: UIAlertController
            var continueButton: UIAlertAction
            var stopButton: UIAlertAction
            
            var message: String
            if GlobalVar.settings.currTimer.autoRepeat {
                message = "Press Continue to start the next timer or press Stop to stop the timer"
            }
            else {
                message = "Press Stop to stop the timer"
            }
            
            alert = UIAlertController(title: "Time out",
                                      message: message, preferredStyle: .alert)

            //TODO: set different value for .positive and .negative timer
            let systemAlarmID = GlobalVar.settings.currTimer.timerAlarm[.positive]!
            
            var timer = Timer()
            AudioServicesPlaySystemSound(SystemSoundID(systemAlarmID))
            if GlobalVar.settings.currTimer.repeatAlarm {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {timer in
                    AudioServicesPlaySystemSound(SystemSoundID(systemAlarmID))
                })
            }
            
            if GlobalVar.settings.currTimer.autoRepeat {
                continueButton = UIAlertAction(title: "Continue", style: .default, handler: {(UIAlertAction) in
                    completion(true)
                    if GlobalVar.settings.currTimer.repeatAlarm {
                        timer.invalidate()
                    }
                })
                alert.addAction(continueButton)
            }
            
            stopButton = UIAlertAction(title: "Stop", style: .cancel, handler: {(UIAlertAction) in
                completion(false)
                if GlobalVar.settings.currTimer.repeatAlarm {
                    timer.invalidate()
                }
            })
            alert.addAction(stopButton)
            
            self.present(alert, animated: true, completion: nil)
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
            self.posTimeValLabel.text = "\(posMinutes)m \(posSeconds)s"
            self.negTimeValLabel.text = "\(negMinutes)m \(negSeconds)s"
            if let completion = completion {
                completion()
            }
        }
    }
    
    func getCurrTime() -> Int {
        let row = mainTimer.selectedRow(inComponent: 1)
        print("[Picker View] getCurrTime() - selectedRow: \(row) seconds: \(MIDDLE_ROW - row)")
        return MIDDLE_ROW - mainTimer.selectedRow(inComponent: 1)
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
        posTimeValLabel.textColor = .none
        negTimeValLabel.textColor = .none
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
        if getCurrTime() > 0 {
            posTimeValLabel.textColor = .cyan
            negTimeValLabel.textColor = .none
        }
        else {
            negTimeValLabel.textColor = .cyan
            posTimeValLabel.textColor = .none
        }
    }
}

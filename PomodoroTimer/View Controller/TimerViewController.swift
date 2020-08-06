//
//  TimerViewController.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class TimerViewController: UIViewController {
    private var lastPanFeedbackMin = 0
    private var spins = 0
    private var enteredThresholdRegion = false
    private var maxMinutes: Int = 0 {
        didSet {
            passedTimePie.maxTime = CGFloat(maxMinutes) * 60
            mainTimer.reloadComponent(components.minVal.rawValue)
            maxMinutesLabel.text = "\(maxMinutes)m"
        }
    }
    private var currTime: Int = 0
    private var panTimerType: TimerType = .positive

    private var defaultTimeInfoStackView = UIStackView()
    private var posInfoStackView = UIStackView()
    private var negInfoStackView = UIStackView()
   
    private var defaultPosTimeLabel = UILabel()
    private var defaultNegTimeLabel = UILabel()
    
    private var defaultPosTimeValLabel = UILabel()
    private var defaultNegTimeValLabel = UILabel()
    
    private var passedTimeInfoStackView = UIStackView()
    
    private var passedPosTimeValLabel = UILabel()
    private var passedNegTimeValLabel = UILabel()
    
    private var maxMinutesLabel = UILabel()
    private var mainTimer = UIPickerView()
    private var startButton = UIButton(type: .system)
    
    private var clockImage = UIImageView()
    private var passedTimePie = TimePieView()
    private var pickerWindow = PickerWindowView()
    
    // MARK: - UIButtons
    @objc func startButtonPressed(_ sender: Any) {
        if GlobalVar.timeController.timerStarted == false {
            print("[Timer View] Pressed Start Button")
            GlobalVar.timeController.startButtonTapped()
        }
        else {
            print("[Timer View] Pressed Stop Button")
            GlobalVar.timeController.stopButtonTapped()
        }
    }
    
    @objc func leftBarPressed() {
        let settingsViewController = SettingsTableViewController(style: .grouped)
        navigationController?.pushViewControllerFromLeft(controller: settingsViewController)
    }
    
    @objc func rightBarPressed() {
        let timerListViewController = TimerListTableViewController(style: .grouped)
        navigationController?.pushViewController(timerListViewController, animated: true)
    }
    
    // MARK: - Gesture
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            if currTime >= 0 {
                panTimerType = .positive
                spins = 0
            }
            else {
                panTimerType = .negative
                spins = -1
            }
            lastPanFeedbackMin = currTime / 60
            enteredThresholdRegion = false
        }
        else {
            guard let view = sender.view else {return}
            let location = sender.location(in: view)
            let velocity = sender.velocity(in: view)
            let center = mainTimer.center
            
            let circleX = location.x - center.x
            let circleY = center.y - location.y
            var angle = abs(atan(circleY / circleX))
            var relAngle: CGFloat
            if circleX >= 0 && circleY >= 0 {
                //First quadrant
                relAngle = angle + .pi * 1.5
            }
            else if circleX < 0 && circleY >= 0 {
                //Second quadrant
                angle = .pi - angle
                relAngle = angle - .pi / 2
            }
            else if circleX < 0 && circleY < 0 {
                //Third quadrant
                angle += .pi
                relAngle = angle - .pi / 2
            }
            else {
                //Fourth quadrant
                angle = 2 * .pi - angle
                relAngle = angle - .pi / 2
            }
            
            let threshold: CGFloat = 0.2
            if relAngle > .pi * 2 - threshold && velocity.x > 0 {
                if enteredThresholdRegion == false {
                    if panTimerType == .negative {
                        print("Negative full circle?")
                    }
                    else {
                        print("Flip to negative?")
                        panTimerType = .negative
                    }
                    spins -= 1
                    enteredThresholdRegion = true
                }
                
            }
            else if relAngle < threshold && velocity.x < 0 {
                if enteredThresholdRegion == false {
                    if panTimerType == .positive {
                        print("Positive full circle?")
                    }
                    else {
                        print("Flip to positive")
                        panTimerType = .positive
                    }
                    spins += 1
                    enteredThresholdRegion = true
                }
            }
            else {
                enteredThresholdRegion = false
            }
            
            relAngle = relAngle + CGFloat(spins) * 2 * .pi
            
            var time = passedTimePie.getTime(angle: relAngle)
            if relAngle >= 2 * .pi {
                relAngle = 2 * .pi
                time = maxMinutes * 60
            }
            else if relAngle <= -2 * .pi {
                relAngle = -2 * .pi
                time = -maxMinutes * 60
            }
            
            print(String(format: "[Timer View] Dragged to Circle x:%.2f y:%.2f angle:%.2f time: %d", circleX, circleY, angle, time))
            passedTimePie.setTime(time: time)
            passedTimePie.setNeedsDisplay()
            
            if abs(lastPanFeedbackMin - time / 60) >= 1 {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                lastPanFeedbackMin = time / 60
            }
            
            setTime(time: time, animated: false)
        }

    }
    
    private func setTime(time: Int, animated: Bool) {
        var seconds = abs(time) % 60
        var minutes = abs(time) / 60
        
        if minutes >= maxMinutes {
            minutes = maxMinutes
            seconds = 0
            currTime = maxMinutes * 60 * time / abs(time)
        }
        else {
            currTime = time
        }

        print("[Timer View] setTime to \(currTime)")
        mainTimer.selectRow(seconds, inComponent: components.secVal.rawValue, animated: animated)
        mainTimer.selectRow(minutes, inComponent: components.minVal.rawValue, animated: animated)

        if currTime >= 0 {
            mainTimer.selectRow(0, inComponent: components.sign.rawValue, animated: animated)
        }
        else {
            mainTimer.selectRow(1, inComponent: components.sign.rawValue, animated: animated)
        }
        
        passedTimePie.setTime(time: currTime)
    }
    
    // MARK: - View Transition Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
        
        //TODO: let user grant the autorization from settings menu even if user pressed no
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("Did user granted autorization? \(granted)")
        }
        
        GlobalVar.timeController.timeControllerDelegate = self
        
        if self.traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if newCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            passedTimePie.backgroundColor = .black
            clockImage.image = UIImage(named: "clockOutline2Inverted")
        } else {
            view.backgroundColor = .white
            passedTimePie.backgroundColor = .white
            clockImage.image = UIImage(named: "clockOutline2")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = GlobalVar.settings.dontSleep
        print("[Timer View] Will this view stay on? \(GlobalVar.settings.dontSleep)")
        
        let currTimer = GlobalVar.settings.currTimer
        navigationItem.title = currTimer.timerName
        maxMinutes = currTimer.maxMinutes
        if !GlobalVar.timeController.timerStarted {
            print("[Timer View] Initializing timer to \(currTimer.startTime[.positive]!)")
            setTime(time: currTimer.startTime[.positive]!, animated: false)
        }
        else if currTime >= maxMinutes * 60 {
            print("[Timer View] current time is larger than maxMinutes")
            setTime(time: maxMinutes * 60, animated: false)
        }
        
        let posTime = currTimer.startTime[.positive]!
        let negTime = currTimer.startTime[.negative]!
        defaultPosTimeValLabel.text = "\(posTime / 60)m \(posTime % 60)s"
        defaultNegTimeValLabel.text = "\(abs(negTime / 60))m \(negTime % 60)s"
    }

    // MARK: - UI Initialization
    
    private func initUI() {
        addViews()
        initUIAttributes()
        initUIConstraints()
        initUIFeatures()
    }
    
    private func addViews() {
        view.addSubview(passedTimePie)
        view.addSubview(pickerWindow)
        view.addSubview(defaultTimeInfoStackView)
        view.addSubview(passedTimeInfoStackView)
        view.addSubview(maxMinutesLabel)
        view.addSubview(mainTimer)
        view.addSubview(startButton)
        view.addSubview(clockImage)
        
        defaultTimeInfoStackView.addArrangedSubview(posInfoStackView)
        defaultTimeInfoStackView.addArrangedSubview(negInfoStackView)
        
        posInfoStackView.addArrangedSubview(defaultPosTimeLabel)
        posInfoStackView.addArrangedSubview(defaultPosTimeValLabel)
        
        negInfoStackView.addArrangedSubview(defaultNegTimeLabel)
        negInfoStackView.addArrangedSubview(defaultNegTimeValLabel)
        
        passedTimeInfoStackView.addArrangedSubview(passedPosTimeValLabel)
        passedTimeInfoStackView.addArrangedSubview(passedNegTimeValLabel)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(pan)
    }
    
    private func initUIAttributes() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(leftBarPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Timers", style: .plain, target: self, action: #selector(rightBarPressed))
        
        defaultPosTimeLabel.text = "Positive:"
        defaultPosTimeLabel.textAlignment = .center
        
        defaultNegTimeLabel.text = "Negative:"
        defaultNegTimeLabel.textAlignment = .center
        
        defaultPosTimeValLabel.text = "0m 0s"
        defaultPosTimeValLabel.textAlignment = .center
        
        defaultNegTimeValLabel.text = "0m 0s"
        defaultNegTimeValLabel.textAlignment = .center
        
        passedPosTimeValLabel.text = "0m 0s"
        passedPosTimeValLabel.textAlignment = .left
        
        passedNegTimeValLabel.text = "0m 0s"
        passedNegTimeValLabel.textAlignment = .right
        
        maxMinutesLabel.text = "\(maxMinutes)m"
        
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = startButton.titleLabel?.font.withSize(25)
        
        defaultTimeInfoStackView.axis = .horizontal
        defaultTimeInfoStackView.distribution = .fillEqually
        defaultTimeInfoStackView.spacing = 0
        
        posInfoStackView.axis = .vertical
        posInfoStackView.distribution = .fillEqually
        posInfoStackView.spacing = 5
        
        negInfoStackView.axis = .vertical
        negInfoStackView.distribution = .fillEqually
        negInfoStackView.spacing = 5
        
        passedTimeInfoStackView.axis = .horizontal
        passedTimeInfoStackView.distribution = .fillEqually
        passedTimeInfoStackView.spacing = 0
        
        passedTimePie.maxTime = CGFloat(maxMinutes * 60)
        
        if self.traitCollection.userInterfaceStyle == .dark {
            passedTimePie.backgroundColor = .black
            clockImage.image = UIImage(named: "clockOutline2Inverted")
        } else {
            passedTimePie.backgroundColor = .white
            clockImage.image = UIImage(named: "clockOutline2")
        }
    }
    
    private func initUIConstraints() {
        defaultTimeInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        defaultTimeInfoStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        defaultTimeInfoStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
        defaultTimeInfoStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0).isActive = true
        
        passedTimeInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        passedTimeInfoStackView.bottomAnchor.constraint(equalTo: clockImage.topAnchor, constant: 20).isActive = true
        passedTimeInfoStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 40).isActive = true
        passedTimeInfoStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -40).isActive = true
        
        maxMinutesLabel.translatesAutoresizingMaskIntoConstraints = false
        maxMinutesLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0).isActive = true
        maxMinutesLabel.bottomAnchor.constraint(equalTo: clockImage.topAnchor, constant: 10).isActive = true
        
        mainTimer.translatesAutoresizingMaskIntoConstraints = false
        mainTimer.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0).isActive = true
        mainTimer.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor, constant: 20).isActive = true
        mainTimer.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.topAnchor.constraint(equalTo: mainTimer.bottomAnchor, constant: 80).isActive = true
        startButton.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0).isActive = true
        
        clockImage.translatesAutoresizingMaskIntoConstraints = false
        clockImage.centerXAnchor.constraint(equalTo: mainTimer.centerXAnchor).isActive = true
        clockImage.centerYAnchor.constraint(equalTo: mainTimer.centerYAnchor).isActive = true
        clockImage.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        clockImage.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        clockImage.heightAnchor.constraint(equalTo: clockImage.widthAnchor).isActive = true
        
        passedTimePie.translatesAutoresizingMaskIntoConstraints = false
        passedTimePie.centerXAnchor.constraint(equalTo: clockImage.centerXAnchor).isActive = true
        passedTimePie.centerYAnchor.constraint(equalTo: clockImage.centerYAnchor).isActive = true
        passedTimePie.widthAnchor.constraint(equalTo: clockImage.widthAnchor, multiplier: 1, constant: -34).isActive = true
        passedTimePie.heightAnchor.constraint(equalTo: passedTimePie.widthAnchor).isActive = true
        
        pickerWindow.translatesAutoresizingMaskIntoConstraints = false
        pickerWindow.centerXAnchor.constraint(equalTo: clockImage.centerXAnchor).isActive = true
        pickerWindow.centerYAnchor.constraint(equalTo: clockImage.centerYAnchor).isActive = true
        pickerWindow.widthAnchor.constraint(equalToConstant: 140).isActive = true
        pickerWindow.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    private func initUIFeatures() {
        mainTimer.dataSource = self
        mainTimer.delegate = self
        
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
}

//MARK: - PickerView

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private enum components: Int {
        case sign
        case minVal
        case secVal
        case blank
        case numberOfComponents
        
        init?(indexPath: NSIndexPath) {
            self.init(rawValue: indexPath.section)
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components.numberOfComponents.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch components(rawValue: component) {
        case .sign:
            return 2
        case .minVal:
            return maxMinutes + 1
        case .secVal:
            return 60
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let timeWidth: CGFloat = 40
        let othersWidth: CGFloat = 20
        switch components(rawValue: component) {
        case .sign:
            return othersWidth
        case .minVal:
            return timeWidth
        case .secVal:
            return timeWidth
        case .blank:
            return othersWidth
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch components(rawValue: component) {
        case .sign:
            if row == 0 {
                return "+"
            }
            else {
                return "-"
            }
        case .minVal:
            return String(row)
        case .secVal:
            return String(row)
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch components(rawValue: component) {
        case .sign:
            print("[Timer View] Sign picker moved")
            let minutes = pickerView.selectedRow(inComponent: components.minVal.rawValue)
            let seconds = pickerView.selectedRow(inComponent: components.secVal.rawValue)
            
            var sign: Int
            if row == 0 {
                sign = 1
            }
            else {
                sign = -1
            }
            let time = (minutes * 60 + seconds) * sign
            
            print("[Timer View] Selected val in Sign: \(sign) Min: \(minutes), in Sec: \(time)")
            
            setTime(time: time, animated: true)
        case .minVal:
            print("[Timer View] Minute picker moved")
            let minutes = row
            let seconds = pickerView.selectedRow(inComponent: components.secVal.rawValue)
            var sign: Int
            if pickerView.selectedRow(inComponent:components.sign.rawValue) == 0 {
                sign = 1
            }
            else {
                sign = -1
            }
            let time = (minutes * 60 + seconds) * sign
            
            print("[Timer View] Selected val in Sign: \(sign) Min: \(minutes), in Sec: \(time)")
            setTime(time: time, animated: true)
        case .secVal:
            print("[Timer View] Second picker moved")
            var seconds = row
            let minutes = pickerView.selectedRow(inComponent: components.minVal.rawValue)
            if minutes == maxMinutes && seconds > 0 {
                pickerView.selectRow(0, inComponent: components.secVal.rawValue, animated: true)
                seconds = 0
            }
            var sign: Int
            if pickerView.selectedRow(inComponent:components.sign.rawValue) == 0 {
                sign = 1
            }
            else {
                sign = -1
            }
            let time = (minutes * 60 + seconds) * sign
            
            print("[Timer View] Selected val in Sign: \(sign) Min: \(minutes), in Sec: \(time)")
            setTime(time: time, animated: true)
        default:
            break
        }
        
        if GlobalVar.timeController.timerStarted {
            print("[Timer View] Moved timer during timing")
        }
    }
}

//MARK: TimeControllerDelegate

extension TimerViewController: TimeControllerDelegate {
    func displayTimeoutAlert(type: TimerType, completion: @escaping ((Bool) -> Void)) {
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

            let systemAlarmID = GlobalVar.alarmSounds.list[GlobalVar.settings.currTimer.timerAlarmID[type]!].systemSoundID
            
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
            print("[Timer View] Setting timer UI to \(currTime) seconds")
            self.setTime(time: currTime, animated: animated)
            
            self.passedPosTimeValLabel.text = "\(posMinutes)m \(posSeconds)s"
            self.passedNegTimeValLabel.text = "\(negMinutes)m \(negSeconds)s"
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    func getCurrTime() -> Int {
        return currTime
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
        passedPosTimeValLabel.textColor = .none
        passedNegTimeValLabel.textColor = .none
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
        if getCurrTime() > 0 {
            passedPosTimeValLabel.textColor = .cyan
            passedNegTimeValLabel.textColor = .none
        }
        else {
            passedNegTimeValLabel.textColor = .cyan
            passedPosTimeValLabel.textColor = .none
        }
    }
}

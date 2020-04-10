//
//  TimerViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/10.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class TimerViewController: UIViewController {
    var lastPanFeedbackMin = 0
    var maxMinutes: Int = 0 {
        didSet {
            passedTimePie.maxTime = CGFloat(maxMinutes) * 60
            mainTimer.reloadComponent(components.minVal.rawValue)
        }
    }
    var currTime: Int = 0
    var panTimerType: TimerType = .positive

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
    
    var clockImage = UIImageView()
    var passedTimePie = TimePieView()
    var pickerWindow = PickerWindowView()
    
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
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    @objc func rightBarPressed() {
        let timerListViewController = TimerListTableViewController(style: .grouped)
        self.navigationController?.pushViewController(timerListViewController, animated: true)
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            if currTime >= 0 {
                panTimerType = .positive
            }
            else {
                panTimerType = .negative
            }
            lastPanFeedbackMin = currTime / 60
        }
        else {
            guard let view = sender.view else {return}
            let location = sender.location(in: view)
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
            if passedTimePie.angle < threshold && relAngle > .pi * 2 - threshold {
                print("Flipped to negative")
                panTimerType = .negative
            }
            else if relAngle < threshold && passedTimePie.angle > threshold - 2 * .pi {
                print("Flipped to positive")
                panTimerType = .positive
            }
                
            if panTimerType == .negative {
                relAngle = relAngle - 2 * .pi
            }
            
            let time = passedTimePie.getTime(angle: relAngle)
            
            print("[Timer View] Dragged to Circle x:\(Int(circleX)) y:\(Int(circleY)) angle:\(angle) time: \(time)")
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
    
    func setTime(time: Int, animated: Bool) {
        var seconds = abs(time) % 60
        var minutes = abs(time) / 60
        
        if minutes >= maxMinutes {
            minutes = maxMinutes
            seconds = 0
            currTime = maxMinutes * 60 * minutes / abs(minutes)
        }
        else {
            currTime = time
        }

        print("[Timer View] setTime to \(currTime)")
        mainTimer.selectRow(59 - seconds, inComponent: components.secVal.rawValue, animated: animated)
        mainTimer.selectRow(maxMinutes - minutes, inComponent: components.minVal.rawValue, animated: animated)

        if currTime >= 0 {
            mainTimer.selectRow(0, inComponent: components.sign.rawValue, animated: animated)
        }
        else {
            mainTimer.selectRow(1, inComponent: components.sign.rawValue, animated: animated)
        }
        
        passedTimePie.setTime(time: currTime)
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
        
        GlobalVar.timeController.timeControllerDelegate = self 
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
    }

    func initUI() {
        addViews()
        initUIAttributes()
        initUIConstraints()
        initUIFeatures()
    }
    
    func addViews() {
        view.addSubview(passedTimePie)
        view.addSubview(pickerWindow)
        view.addSubview(passedTimeLabel)
        view.addSubview(timeInfoStackView)
        view.addSubview(pickerInfoStackView)
        view.addSubview(mainTimer)
        view.addSubview(startButton)
        view.addSubview(clockImage)
        
        timeInfoStackView.addArrangedSubview(posInfoStackView)
        timeInfoStackView.addArrangedSubview(negInfoStackView)
        
        posInfoStackView.addArrangedSubview(posTimeLabel)
        posInfoStackView.addArrangedSubview(posTimeValLabel)
        
        negInfoStackView.addArrangedSubview(negTimeLabel)
        negInfoStackView.addArrangedSubview(negTimeValLabel)
        
        pickerInfoStackView.addArrangedSubview(pickerInfoMinutesLabel)
        pickerInfoStackView.addArrangedSubview(pickerInfoSecondsLabel)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(pan)
    }
    
    func initUIAttributes() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(leftBarPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Timers", style: .plain, target: self, action: #selector(rightBarPressed))
        
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
        
        clockImage.image = UIImage(named: "clockOutline2Inverted")
        
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
        
        passedTimePie.maxTime = CGFloat(maxMinutes * 60)
        passedTimePie.backgroundColor = .black
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
        pickerInfoStackView.bottomAnchor.constraint(equalTo: mainTimer.topAnchor, constant: -10).isActive = true
        pickerInfoStackView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor).isActive = true
        pickerInfoStackView.widthAnchor.constraint(equalToConstant: 160).isActive = true
 
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
        
        //TODO: decide to keep this stackview or not
        pickerInfoStackView.isHidden = true
    }
    
    func initUIFeatures() {
        mainTimer.dataSource = self
        mainTimer.delegate = self
        
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
    }
}

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    enum components: Int {
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
            return String(maxMinutes - row)
        case .secVal:
            return String(59 - row)
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch components(rawValue: component) {
        case .sign:
            print("[Timer View] Sign picker moved")
            let minutes = maxMinutes - pickerView.selectedRow(inComponent: components.minVal.rawValue)
            let seconds = 59 - pickerView.selectedRow(inComponent: components.secVal.rawValue)
            
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
            let minutes = maxMinutes - row
            let seconds = 59 - pickerView.selectedRow(inComponent: components.secVal.rawValue)
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
            var seconds = 59 - row
            let minutes = maxMinutes - pickerView.selectedRow(inComponent: components.minVal.rawValue)
            if minutes == maxMinutes && seconds > 0 {
                pickerView.selectRow(59, inComponent: components.secVal.rawValue, animated: true)
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

extension TimerViewController: TimeControllerDelegate {
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
            print("[Timer View] Setting timer UI to \(currTime) seconds")
            self.setTime(time: currTime, animated: animated)
            
            self.posTimeValLabel.text = "\(posMinutes)m \(posSeconds)s"
            self.negTimeValLabel.text = "\(negMinutes)m \(negSeconds)s"
            
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

//
//  CircleViewController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController {

    let increment: CGFloat = 30 // Pi (180 degrees) = ${increment} seconds
    var currDegree: CGFloat = 0
    @IBOutlet weak var clockHand: UIImageView!
    @IBOutlet weak var clockImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        if GlobalVar.timeController.timerStarted == false {
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GlobalVar.timeController.timeControllerDelegate = self
    }
    
    func initUI() {
        startButton.setTitle("Start", for: .normal)
        if self.traitCollection.userInterfaceStyle == .dark {
            clockImage.image = UIImage(named: "clockOutline2Inverted")
        } else {
            clockImage.image = UIImage(named: "clockOutline2")
        }
        clockHand.image = UIImage(named: "redArrowHalf")
        clockHand.transform = self.clockHand.transform.rotated(by: .pi/2)
        clockImage.transform = clockImage.transform.translatedBy(x: 0, y: -10)
    }
}

extension CircleViewController: TimeControllerDelegate {
    func displayTimeoutAlert(completion: @escaping ((Bool) -> Void)) {
        //TODO: implement the UI
    }
    
    func setSecondUI(currTime: Int, passedTime: [TimerType: Double], animated: Bool, completion: (() -> ())?) {
        let newDegree = .pi / increment * CGFloat(currTime)
        let diffDegree = currDegree - newDegree
        
        DispatchQueue.main.async {
            self.clockHand.transform = self.clockHand.transform.rotated(by: diffDegree)
            if let completion = completion {
                completion()
            }
        }
        currDegree = newDegree
    }
    
    func getCurrTime() -> Int {
        let seconds = Int(round(currDegree / .pi * self.increment))
        print("[Circle View] currDegree: \(currDegree) seconds: \(seconds)")
        return seconds
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
    }
}

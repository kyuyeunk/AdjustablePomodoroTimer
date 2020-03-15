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
        self.clockHand.transform = self.clockHand.transform.rotated(by: .pi/2)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CircleViewController: TimeControllerDelegate {
    func setSecondUI(currTime: Int, completion: (() -> ())?) {
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
        let seconds = Int(ceil(currDegree / .pi * self.increment))
        print("currDegree: \(currDegree) seconds: \(seconds)")
        return seconds
    }
    
    func stopTimerUI() {
        startButton.setTitle("Start", for: .normal)
    }
    
    func startTimerUI() {
        startButton.setTitle("Stop", for: .normal)
    }
}

// Copied from https://stackoverflow.com/a/48626579
extension UIBezierPath {
    func addArrow(start: CGPoint, end: CGPoint, pointerLineLength: CGFloat, arrowAngle: CGFloat) {
        self.move(to: start)
        self.addLine(to: end)

        let startEndAngle = atan((end.y - start.y) / (end.x - start.x)) + ((end.x - start.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowLine1 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: end.x + pointerLineLength * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle), y: end.y - pointerLineLength * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))

        self.addLine(to: arrowLine1)
        self.move(to: end)
        self.addLine(to: arrowLine2)
    }
}

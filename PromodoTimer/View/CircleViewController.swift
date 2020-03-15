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
    var currDegree: CGFloat = .pi / 2
    @IBOutlet weak var redBarImage: UIImageView!
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
            clockImage.image = UIImage(named: "clockOutlineInverted")
        } else {
            clockImage.image = UIImage(named: "clockOutline")
        }
        redBarImage.image = UIImage(named: "redBar")
        self.redBarImage.transform = self.redBarImage.transform.rotated(by: currDegree)
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
            self.redBarImage.transform = self.redBarImage.transform.rotated(by: diffDegree)
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

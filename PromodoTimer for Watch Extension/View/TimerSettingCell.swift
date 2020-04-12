//
//  TimerSettingCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class TimerSettingCell: NSObject {
    @IBOutlet weak var settingLabel: WKInterfaceLabel!
    @IBOutlet weak var settingValue: WKInterfaceSlider!
    @IBAction func sliderTapped(_ value: Float) {
        print("Slider tapped to \(value)")
        currValue = value
    }
    
    var currValue: Float = 0
    
    func setValue(value: Int) {
        currValue = Float(value)
        settingValue.setValue(Float(value))
    }
}

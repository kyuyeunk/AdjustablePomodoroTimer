//
//  TimerSettingCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class SliderSettingCell: NSObject {
    @IBOutlet weak var settingValueLabel: WKInterfaceLabel!
    @IBOutlet weak var settingLabel: WKInterfaceLabel!
    @IBOutlet weak var settingValueSlider: WKInterfaceSlider!
    @IBAction func sliderTapped(_ value: Float) {
        print("Slider tapped to \(value)")
        currValue = value
        updateLabel(value: Int(value))
    }
    
    var currValue: Float = 0
    
    func setValue(value: Int) {
        currValue = Float(value)
        settingValueSlider.setValue(Float(value))
        settingValueLabel.setText(String(value))
    }
    
    func updateLabel(value: Int) {
        settingValueLabel.setText(String(value))
    }
}

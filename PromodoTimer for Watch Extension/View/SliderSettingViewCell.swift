//
//  TimerSettingCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

protocol SliderSettingDelegate {
    func updateSliderValue(sliderSettingViewCell: SliderSettingViewCell, value: Int)
}

class SliderSettingViewCell: NSObject {
    var sliderUpdateDelegate: SliderSettingDelegate?
    @IBOutlet weak var settingValueLabel: WKInterfaceLabel!
    @IBOutlet weak var settingLabel: WKInterfaceLabel!
    @IBOutlet weak var settingValueSlider: WKInterfaceSlider!
    @IBAction func sliderTapped(_ value: Float) {
        print("Slider tapped to \(value)")
        currValue = Int(round(value / 100 * Float(maxValue)))
        if currValue == 0 {
            setValue(value: 1)
        }
        else {
            updateLabel(value: currValue)
            if let delegate = sliderUpdateDelegate {
                delegate.updateSliderValue(sliderSettingViewCell: self, value: currValue)
            }
        }
    }
    
    var currValue: Int = 0
    var maxValue: Int = 60
    
    func setValue(value: Int) {
        print("Setting value to \(value)")
        
        currValue = value
        let sliderValue = Float(value) / Float(maxValue) * 100
        settingValueSlider.setValue(sliderValue)
        updateLabel(value: value)
    }
    
    func setMaxValue(value: Int) {
        print("Setting Max Value to \(value)")
        maxValue = value
        settingValueSlider.setNumberOfSteps(value)
    }
    
    func updateLabel(value: Int) {
        print("Setting label value to \(value)")
        settingValueLabel.setText("\(value)m")
    }
}

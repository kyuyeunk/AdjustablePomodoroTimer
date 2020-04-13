//
//  SwitchSettingCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

class SwitchSettingViewCell: NSObject {
    @IBOutlet weak var settingValueSwitch: WKInterfaceSwitch!
    @IBAction func switchTapped(_ value: Bool) {
        print(value)
    }
    
}

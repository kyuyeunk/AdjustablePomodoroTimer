//
//  TextFieldViewCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/14.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

protocol TextFieldDelegate {
    func TextFieldTapped(value: String)
}


class TimerNameViewCell: NSObject {
    var textFieldDelegate: TextFieldDelegate!
    
    @IBOutlet weak var textField: WKInterfaceTextField!
    @IBAction func textFieldTapped(_ value: NSString?) {
        if let value = value {
            let valueStr = String(value)
            print(valueStr)
            textFieldDelegate.TextFieldTapped(value: valueStr)
        }
    }
}

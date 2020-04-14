//
//  ButtonWithLabelViewCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

protocol ButtonWithLabelDelegate {
    func buttonTapped(buttonWithLabelViewCell: ButtonWithLabelViewCell)
}

class ButtonWithLabelViewCell: NSObject {
    var buttonDelegate: ButtonWithLabelDelegate?
    @IBOutlet weak var button: WKInterfaceButton!
    @IBAction func buttonTapped() {
        WKInterfaceDevice.current().play(.click)
        if let delegate = buttonDelegate {
            delegate.buttonTapped(buttonWithLabelViewCell: self)
        }
    }
}

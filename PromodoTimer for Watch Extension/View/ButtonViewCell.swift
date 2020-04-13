//
//  ButtonViewCell.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/13.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit

protocol ButtonDelegate {
    func buttonTapped(buttonViewCell: ButtonViewCell)
}

class ButtonViewCell: NSObject {
    var buttonDelegate: ButtonDelegate?
    @IBOutlet weak var button: WKInterfaceButton!
    @IBAction func buttonTapped() {
        WKInterfaceDevice.current().play(.click)
        if let delegate = buttonDelegate {
            delegate.buttonTapped(buttonViewCell: self)
        }
    }
    
}

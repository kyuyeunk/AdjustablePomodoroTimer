//
//  PickerWindowView.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/04/09.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

class PickerWindowView: UIView {
    override func draw(_ rect: CGRect) {
        var color: UIColor
        if self.traitCollection.userInterfaceStyle == .dark {
            color = UIColor.black
        } else {
            color = UIColor.white
        }
        
        let drect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let path: UIBezierPath = UIBezierPath(rect: drect)
        
        path.close()
        color.setFill()
        path.fill()
    }
    
    
}

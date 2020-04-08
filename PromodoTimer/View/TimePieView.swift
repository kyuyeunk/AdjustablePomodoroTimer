//
//  TimePieView.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/04/08.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import UIKit

// Inspired by https://stackoverflow.com/a/38260553
class TimePieView : UIView {
    var endTime: CGFloat = 0
    var max: CGFloat = 60 * 60
    let path = UIBezierPath()
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = -(CGFloat.pi / 2 + endTime / max * CGFloat.pi * 2)
        
        var clockwise: Bool
        var color: UIColor
        
        if endTime > 0 {
            clockwise = false
            color = .red
        }
        else {
            clockwise = true
            color = .blue
        }
        
        print("[TimePieView] startAngle: \(startAngle) endAngle: \(endAngle)")
        let path = UIBezierPath()
        path.move(to: center)
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        path.close()
        color.setFill()
        path.fill()
    }
    
    func setTime(time: Int) {
        endTime = CGFloat(time)
        self.setNeedsDisplay()
    }
    
    func getTime(angle: CGFloat) -> Int{
        return Int(angle / (2 * .pi) * max)
    }
}

//
//  TimePiewView.swift
//  PomodoroTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation
import WatchKit
import SpriteKit

class TimePieView {
    var endTime: Int
    var maxTime: Int
    var angle: CGFloat = 0
    let circleSKScene = SKScene(size: CGSize(width: 100, height: 100))
    var isHighlighted = false
    var isRunning = false
    
    init(maxMinute: Int, time endTime: Int) {
        circleSKScene.scaleMode = .aspectFit
        self.maxTime = maxMinute * 60
        self.endTime = endTime
        self.angle = 0
    }
    
    func draw() {
        circleSKScene.removeAllChildren()
        drawOutline()
        drawCircle()
    }
    
    func drawOutline() {
        let path = UIBezierPath(arcCenter: .zero, radius: 48.5, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
        let shapeNode = SKShapeNode(path: path)
        var color: UIColor
        if isHighlighted {
            color = .green
        }
        else if isRunning {
            color = .magenta
        }
        else {
            color = .lightGray
        }
        shapeNode.strokeColor = color
        shapeNode.lineWidth = 3
        shapeNode.position = CGPoint(x: circleSKScene.size.width / 2, y: circleSKScene.size.height / 2)
        circleSKScene.backgroundColor = .black
        circleSKScene.addChild(shapeNode)
    }
    
    func drawCircle() {
        let startAngle: CGFloat = .pi / 2
        let endAngle = getAngle(time: endTime)
        var clockwise: Bool
        var color: UIColor
        if endTime >= 0 {
            clockwise = true
            color = .red
        }
        else {
            clockwise = false
            color = .blue
        }
        
        angle = endAngle - startAngle
        
        print("[Draw Circle] startAngle: \(startAngle) endAngle: \(endAngle) clockwise: \(clockwise)")
        let path = UIBezierPath()
        let center: CGPoint = .zero
        path.move(to: center)
        path.addArc(withCenter: center, radius: 47, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        path.close()
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.fillColor = color
        shapeNode.lineWidth = 0
        shapeNode.strokeColor = color
        shapeNode.position = CGPoint(x: circleSKScene.size.width / 2, y: circleSKScene.size.height / 2)
        circleSKScene.backgroundColor = .black
        circleSKScene.addChild(shapeNode)
    }
    
    func getAngle(time: Int) -> CGFloat {
        return .pi / 2 + CGFloat(time) / CGFloat(maxTime) * CGFloat.pi * 2
    }
    
    func setTime(time: Int) {
        endTime = time
        draw()
    }
    
    func getTime(angle: CGFloat) -> Int{
        return Int(angle / (2 * .pi) * CGFloat(maxTime))
    }
}

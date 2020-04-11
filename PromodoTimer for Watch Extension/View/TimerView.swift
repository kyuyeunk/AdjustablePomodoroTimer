//
//  TimerView.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import SwiftUI

struct TimerView: View {
    var timer: TimerModel
    @State private var sign: Int = 0
    @State private var minRow: Int
    @State private var secRow: Int
    
    let minMaxRow: Int
    let secMaxRow = 59
    
    init(timer: TimerModel) {
        self.timer = timer
        minMaxRow = timer.maxMinutes
        let startPosTime = timer.startTime[.positive]!
        
        let posMin = minMaxRow - startPosTime / 60
        let posSec = secMaxRow - startPosTime % 60
        
        _minRow = .init(initialValue: posMin)
        _secRow = .init(initialValue: posSec)
    }
    
    var body: some View {
        let signStr = ["+", "-"]
        
        let ret = VStack {
            Text("\(signStr[sign]) \(minMaxRow - minRow)m \(secMaxRow - secRow)s")
            Spacer()
            .frame(height: 10)
            HStack {
                Picker(selection: $sign, label: Text("Sign")) {
                    ForEach((0 ..< signStr.count)) { i in
                        Text(signStr[i])
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 24, height: 70)
                
                Picker(selection: $minRow, label: Text("Min")) {
                    ForEach((0 ..< minMaxRow + 1)) { i in
                        Text(String(self.minMaxRow - i))
                    }
                }
                .frame(width: 36, height: 70)
                
                Picker(selection: $secRow, label: Text("Sec")) {
                    ForEach((0 ..< secMaxRow + 1)) { i in
                        Text(String(self.secMaxRow - i))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 36, height: 70)
            }
        }.navigationBarTitle("Timer")
        
        return ret
    }
}

/*
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
*/

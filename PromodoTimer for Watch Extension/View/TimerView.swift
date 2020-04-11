//
//  TimerView.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import SwiftUI

struct TimerView: View {
    @State private var sign: Int = 0
    @State private var min: Int = 59
    @State private var sec: Int = 59
    
    var body: some View {
        var time: [Int] = []
        for i in (0 ..< 60).reversed() {
            time.append(i)
        }
        let signStr = ["+", "-"]
        
        let ret = VStack {
            Text("\(signStr[sign]) \(time[min])m \(time[sec])s")
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
                
                Picker(selection: $min, label: Text("Min")) {
                    ForEach((0 ..< time.count)) { i in
                        Text(String(time[i]))
                    }
                }
                .frame(width: 36, height: 70)
                
                Picker(selection: $sec, label: Text("Min")) {
                    ForEach((0 ..< time.count)) { i in
                        Text(String(time[i])).tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 36, height: 70)
            }
            
        }
        
        return ret
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

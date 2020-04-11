//
//  TimerListView.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import SwiftUI

struct TimerListView: View {
    var timers: [TimerModel] = [TimerModel()]
    
    var body: some View {
        List(timers) { timer in
            NavigationLink(destination: TimerView()) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(timer.timerName)
                    TimerListCell(posTime: timer.startTime[.positive]!, negTime: timer.startTime[.negative]!)
                }
                .padding(3)
            }
        }
        .navigationBarTitle("Timers")
    }
}

struct TimerListCell: View {
    var posTime: Int
    var negTime: Int
    
    var body: some View {
        var posMin: Int { posTime / 60}
        var posSec: Int { posTime % 60}

        var negMin: Int { negTime / 60 }
        var negSec: Int { negTime % 60 }
        
        return HStack() {
            Text(String("\(posMin)m \(posSec)s"))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.red)
            Text(String("\(negMin)m \(negSec)s"))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.blue)
        }
    }
}

struct TimerListView_Previews: PreviewProvider {
    static var previews: some View {
        TimerListView()
    }
}

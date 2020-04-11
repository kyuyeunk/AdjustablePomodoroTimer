//
//  HostingController.swift
//  PromodoTimer for Watch Extension
//
//  Created by Kyu Yeun Kim on 2020/04/11.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<TimerListView> {
    override var body: TimerListView {
        return TimerListView()
    }
}

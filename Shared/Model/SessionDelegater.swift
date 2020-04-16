//
//  SessionDelegate.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/04/16.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation
import WatchConnectivity

extension Notification.Name {
    static let messageReceived = Notification.Name("MessageReceived")
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

class SessionDelegater: NSObject, WCSessionDelegate {
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Hello")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Sending")
        NotificationCenter.default.post(name: .activationDidComplete, object: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Receiving")
        NotificationCenter.default.post(name: .messageReceived, object: nil)
    }
}


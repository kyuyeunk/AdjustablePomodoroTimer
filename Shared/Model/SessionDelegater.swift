//
//  SessionDelegate.swift
//  PomodoroTimer
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
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activated")
        #if os(iOS)
        GlobalVar.settings.sendTogglInfo(replyHandler: nil)
        #endif
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Received Message with Handler")
        if message[WCSessionRequest.request] as? String == WCSessionRequest.togglInfo {
            print("Sending Toggl Info")
            GlobalVar.settings.sendTogglInfo(replyHandler: replyHandler)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Received Message Data")
        let propertyListDecoder = PropertyListDecoder()
        if let decodedTimers = try? propertyListDecoder.decode([TimerModel].self, from: messageData) {
            print("[Received] Timers received")
            let receivedTimers = decodedTimers
            for timer in receivedTimers {
                print("[Received] \(timer.timerName) w pos: \(timer.startTime[.positive]!), neg: \(timer.startTime[.negative]!)")
            }
        }
        else if let receivedTogglInfo = try? propertyListDecoder.decode(togglInfo.self, from: messageData)  {
            GlobalVar.settings.receiveTogglInfo(receivedTogglInfo: receivedTogglInfo)
        }
    }
}

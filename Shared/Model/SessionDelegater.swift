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
        print("[Session Delegater] Activated")
        #if os(iOS)
        GlobalVar.settings.sendTogglInfo(replyHandler: nil)
        #endif
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("[Session Delegater] Received Message with Handler")
        
        if message[WCSessionMessageType.requestTogglInfo] as? Bool == true {
            print("[Session Delegater] Sending Toggl Info")
            GlobalVar.settings.sendTogglInfo(replyHandler: replyHandler)
        }
        else if let messageData = message[WCSessionMessageType.timerList] as? Data {
            let propertyListDecoder = PropertyListDecoder()
            if let receivedSyncListInfo = try? propertyListDecoder.decode(syncListInfo.self, from: messageData) {
                print("[Session Delegater] Timers received")
                GlobalVar.settings.receiveTimerList(receivedSyncListInfo: receivedSyncListInfo, replyHandler: replyHandler)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[Session Delegater] Received Message Data")
        let propertyListDecoder = PropertyListDecoder()
        if let messageData = message[WCSessionMessageType.togglInfo] as? Data,
            let receivedTogglInfo = try? propertyListDecoder.decode(togglInfo.self, from: messageData)  {
            GlobalVar.settings.receiveTogglInfo(receivedTogglInfo: receivedTogglInfo)
        }
        else if let messageData = message[WCSessionMessageType.startTimer] as? Int {
            print("Received start timer \(messageData)")
        }
        else if message[WCSessionMessageType.stopTimer] as? Bool == true {
            print("Received stop timer")
        }
    }
}


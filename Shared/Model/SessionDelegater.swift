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
        GlobalVar.settings.sendTogglInfo()
        #endif
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Received Message with Handler")
        if message[WCSessionRequest.request] as? String == WCSessionRequest.togglCredential {
            print("Sending Credential")
            //TODO: Should also send project list
            let propertyListEncoder = PropertyListEncoder()
            guard let encodedCrednetial = try? propertyListEncoder.encode(GlobalVar.settings.togglCredential) else {
                return
            }
            guard let encodedProjects = try? propertyListEncoder.encode(GlobalVar.settings.projectList) else {
                return
            }
            
            let replyMessage = [WCSessionRequest.togglCredential: [encodedCrednetial, encodedProjects]]
            replyHandler(replyMessage)
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
        else if let decodedCredential = try? propertyListDecoder.decode(credential.self, from: messageData) {
            GlobalVar.settings.receiveTogglCredential(credential: decodedCredential)

        }
        else if let decodedProjects = try? propertyListDecoder.decode([projectInfo].self, from: messageData) {
            GlobalVar.settings.receiveTogglProjects(projectList: decodedProjects)
        }
    }
}


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
        #if os(iOS)
        print("Sending Toggl Credentials")
        let propertyListEncoder = PropertyListEncoder()
        if let encodedCrednetial = try? propertyListEncoder.encode(GlobalVar.settings.togglCredential) {
            WCSession.default.sendMessageData(encodedCrednetial, replyHandler: nil, errorHandler: nil)
        }
        if let encodedProjects = try? propertyListEncoder.encode(GlobalVar.settings.projectList) {
            WCSession.default.sendMessageData(encodedProjects, replyHandler: nil, errorHandler: nil)
        }
        #endif
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Receiving Message")
        NotificationCenter.default.post(name: .messageReceived, object: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Receiving")
        let propertyListDecoder = PropertyListDecoder()
        if let decodedTimers = try? propertyListDecoder.decode([TimerModel].self, from: messageData) {
            print("[Received] Timers received")
            let receivedTimers = decodedTimers
            for timer in receivedTimers {
                print("[Received] \(timer.timerName) w pos: \(timer.startTime[.positive]!), neg: \(timer.startTime[.negative]!)")
            }
        }
        else if let decodedCredential = try? propertyListDecoder.decode(credential.self, from: messageData) {
            print("[Received] Toggl Credentials received")
            
            GlobalVar.settings.togglCredential = decodedCredential
            if let id = decodedCredential.id, let auth = decodedCredential.auth {
                print("[Load] id: \(id)")
                print("[Load] auth: \(auth)")
            }
        }
        else if let decodedProjects = try? propertyListDecoder.decode([projectInfo].self, from: messageData) {
            print("[Received] Projects retrieved")
            GlobalVar.settings.projectList = decodedProjects
            for project in decodedProjects {
                print("[Received] \(project.pid): \(project.name)")
            }
        }
    }
}


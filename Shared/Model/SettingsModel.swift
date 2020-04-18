//
//  SettingsModel.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation
import WatchConnectivity

class Settings {
    var currTimerID: Int = 0 {
        didSet {
            saveMiscs()
        }
    }
    var dontSleep: Bool = false {
        didSet {
            saveMiscs()
        }
    }
    var tickingSound: Bool = false {
        didSet {
            saveMiscs()
        }
    }
    
    var currTimer: TimerModel {
        return timerList[currTimerID]
    }
    
    var togglLoggedIn: Bool {
        return togglCredential.auth != nil
    }
    
    var projectList: [projectInfo] = []
    
    var togglCredential = credential()

    var timerList: [TimerModel] = []
    
    private var settingsDirectory = directories()
    
    init () {
        loadFiles()
        
        if timerList.count == 0 {
            timerList.append(TimerModel())
            currTimerID = 0
        }
        else if timerList.count <= currTimerID || currTimerID < 0 {
            print("ERROR: Bugfound, currTimerID \(currTimerID) is not a valid number")
            currTimerID = 0
        }
    }
    
    func loadFiles() {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedCredential = try? Data(contentsOf: settingsDirectory.credentialArchieveURL),
            let decodedCredential = try? propertyListDecoder.decode(credential.self, from: retrievedCredential){
            
            togglCredential = decodedCredential
            
            if let id = decodedCredential.id, let auth = decodedCredential.auth {
                print("[Load] id: \(id)")
                print("[Load] auth: \(auth)")
            }
        }
        if let retrievedProjects = try? Data(contentsOf: settingsDirectory.projectsArchieveURL),
            let decodedProjects = try? propertyListDecoder.decode([projectInfo].self, from: retrievedProjects) {
            print("[Load] Projects retrieved")
            projectList = decodedProjects
            for project in projectList {
                print("[Load] \(project.pid): \(project.name)")
            }
        }
        if let retrievedTimers = try? Data(contentsOf: settingsDirectory.timersArchieveURL),
            let decodedTimers = try? propertyListDecoder.decode([TimerModel].self, from: retrievedTimers) {
            print("[Load] Timers retrieved")
            timerList = decodedTimers
            for timer in self.timerList {
                print("[Load] \(timer.timerName) w pos: \(timer.startTime[.positive]!), neg: \(timer.startTime[.negative]!)")
            }
        }
        if let retrievedMiscs = try? Data(contentsOf: settingsDirectory.miscsArchieveURL),
            let decodedMiscs = try? propertyListDecoder.decode(miscInfo.self, from: retrievedMiscs) {
            print("[Load] Miscs retrieved")
            currTimerID = decodedMiscs.currTimerID
            dontSleep = decodedMiscs.dontSleep
            tickingSound = decodedMiscs.tickingSound
        }
    }
    
    func setAndSaveAuth(id: String?, auth: String?) {
        togglCredential.auth = auth
        togglCredential.id = id
        let cred = credential(id: id, auth: auth)
        let propertyListEncoder = PropertyListEncoder()
        let encodedCrednetial = try? propertyListEncoder.encode(cred)
        try? encodedCrednetial?.write(to: settingsDirectory.credentialArchieveURL)
        
        if let id = id, let auth = auth {
            print("[Save] id: \(id)")
            print("[Save] auth: \(auth)")
        }
        else {
            print("[Save] id: nil")
            print("[Save] auth: nil")
        }
    }
    
    func setAndSaveProjectList(projects: [[String: Any]]) {
        projectList = []
        for project in projects {
            if project["server_deleted_at"] == nil, let pid = project["id"] as? Int, let name = project["name"] as? String {
                projectList.append(projectInfo(pid: pid, name: name))
            }
        }
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedProjects = try? propertyListEncoder.encode(projectList)
        try? encodedProjects?.write(to: settingsDirectory.projectsArchieveURL)
        
        print("[Save] Projects saved")
        for project in projectList {
            print("[Save] \(project.pid): \(project.name)")
        }
    }
    
    func saveTimerList() {
        let propertyListEncoder = PropertyListEncoder()
        let encodedtimers = try? propertyListEncoder.encode(self.timerList)
        try? encodedtimers?.write(to: settingsDirectory.timersArchieveURL)
        
        print("[Save] Timers saved")
        for timer in self.timerList {
            print("[Save] \(timer.timerName) w pos: \(timer.startTime[.positive]!), neg: \(timer.startTime[.negative]!)")
        }
    }
    
    func saveMiscs() {
        let propertyListEncoder = PropertyListEncoder()
        let miscs = miscInfo(currTimerID: currTimerID, dontSleep: dontSleep, tickingSound: tickingSound)
        let encodedMiscs = try? propertyListEncoder.encode(miscs)
        try? encodedMiscs?.write(to: settingsDirectory.miscsArchieveURL)
        
        print("[Save] Miscs saved")
    }
    
    func sendTogglInfo() {
        print("Sending Toggl Credentials")
        let propertyListEncoder = PropertyListEncoder()
        if let encodedCrednetial = try? propertyListEncoder.encode(GlobalVar.settings.togglCredential) {
            WCSession.default.sendMessageData(encodedCrednetial, replyHandler: nil, errorHandler: nil)
        }
        if let encodedProjects = try? propertyListEncoder.encode(GlobalVar.settings.projectList) {
            WCSession.default.sendMessageData(encodedProjects, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func sendTimerData() {
        print("Sending Data to other device")
        let propertyListEncoder = PropertyListEncoder()
        if let encodedtimers = try? propertyListEncoder.encode(self.timerList) {
            WCSession.default.sendMessageData(encodedtimers, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func receiveTogglCredential(credential: credential) {
        print("[Received] Toggl Credentials received")
        togglCredential = credential
        if let id = togglCredential.id, let auth = togglCredential.auth {
            print("[Received] id: \(id)")
            print("[Received] auth: \(auth)")
        }
    }
    
    func receiveTogglProjects(projectList: [projectInfo]) {
        print("[Received] Projects retrieved")
        GlobalVar.settings.projectList = projectList
        for project in projectList {
            print("[Received] \(project.pid): \(project.name)")
        }
    }
}

struct directories {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var credentialArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("credential").appendingPathExtension("plist")
    }
    var projectsArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("projects").appendingPathExtension("plist")
    }
    var timersArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("timers").appendingPathExtension("plist")
    }
    var miscsArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("miscs").appendingPathExtension("plist")
    }
}
struct credential: Codable {
    var id: String?
    var auth: String?
    
    init(id: String?, auth: String?) {
        self.id = id
        self.auth = auth
    }
    
    init() {
        
    }
}

struct projectInfo: Codable {
    var pid: Int
    var name: String
    init(pid: Int, name: String) {
        self.pid = pid
        self.name = name
    }
}

struct trackingInfo: Codable {
    var auth: String
    var project: projectInfo
    var desc: String
    
    init(project: projectInfo, desc: String) {
        self.project = project
        self.desc = desc
        
        if let auth = GlobalVar.settings.togglCredential.auth {
            self.auth = auth
        }
        else {
            print("ERROR: auth for this trackingInfo is not available")
            self.auth = ""
        }
    }
}

struct miscInfo: Codable {
    var currTimerID: Int
    var dontSleep: Bool
    var tickingSound: Bool
    init(currTimerID: Int, dontSleep: Bool, tickingSound: Bool) {
        self.currTimerID = currTimerID
        self.dontSleep = dontSleep
        self.tickingSound = tickingSound
    }
}

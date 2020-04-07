//
//  SettingsModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

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
    
    var currTimer: TimerModel {
        return timerList[currTimerID]
    }
    
    var projectList: [projectInfo] = []
    
    var togglCredential = credential()

    var timerList: [TimerModel] = []
    
    var settingsDirectory = directories()
    
    init () {
        loadFiles()
        
        if timerList.count == 0 {
            timerList.append(TimerModel())
            currTimerID = 0
        }
        else if timerList.count < currTimerID {
            print("ERROR: Bugfound, currTimerID is larger than timer count")
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
        }
    }
    
    func setAndSaveAuth(id: String, auth: String) {
        togglCredential.auth = auth
        togglCredential.id = id
        let cred = credential(id: id, auth: auth)
        let propertyListEncoder = PropertyListEncoder()
        let encodedCrednetial = try? propertyListEncoder.encode(cred)
        try? encodedCrednetial?.write(to: settingsDirectory.credentialArchieveURL)
        
        print("[Save] id: \(id)")
        print("[Save] auth: \(auth)")
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
        let miscs = miscInfo(currTimerID: currTimerID, dontSleep: dontSleep)
        let encodedMiscs = try? propertyListEncoder.encode(miscs)
        try? encodedMiscs?.write(to: settingsDirectory.miscsArchieveURL)
        
        print("[Save] Miscs saved")
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
    
    init(id: String, auth: String) {
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
    var project: projectInfo
    var desc: String
    init(project: projectInfo, desc: String) {
        self.project = project
        self.desc = desc
    }
}

struct miscInfo: Codable {
    var currTimerID: Int
    var dontSleep: Bool
    init(currTimerID: Int, dontSleep: Bool) {
        self.currTimerID = currTimerID
        self.dontSleep = dontSleep
    }
}

//
//  SettingsModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class Settings {
    var currTimer: Int = 0
    
    var currPostStartTime: Int {
        return timerList[currTimer].startTime[.positive]!
    }
    var currNegStartTime: Int {
        return timerList[currTimer].startTime[.negative]!
    }
    var currAutoRepeat: Bool {
        return timerList[currTimer].autoRepeat
    }
    
    var projectList: [projectInfo] = []
    
    var togglCredential: credential?

    var timerList: [TimerModel] = []
    
    var settingsDirectory = directories()
    
    init () {
        loadFiles()
        
        if timerList.count == 0 {
            timerList.append(TimerModel())
            currTimer = 0
        }
    }
    
    func loadFiles() {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedCredential = try? Data(contentsOf: settingsDirectory.credentialArchieveURL),
            let decodedCredential = try? propertyListDecoder.decode(credential.self, from: retrievedCredential){
            
            togglCredential = decodedCredential
            
            print("[Load] id: \(decodedCredential.id)")
            print("[Load] auth: \(decodedCredential.auth)")
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
    }
    
    func setAndSaveAuth(id: String, auth: String) {
        self.togglCredential?.auth = auth
        self.togglCredential?.id = id
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
}
struct credential: Codable {
    var id: String
    var auth: String
    init(id: String, auth: String) {
        self.id = id
        self.auth = auth
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

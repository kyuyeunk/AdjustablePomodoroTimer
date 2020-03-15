//
//  SettingsModel.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/15.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class Settings {
    var projects: [projectInfo] = []
    var userDefinedTracking: [TrackingType: trackingInfo] = [:]
    var id: String = "Please Input ID/PW"
    var auth: String = ""            //TODO: learn about keychain for better encryption
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var credentialArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("credential").appendingPathExtension("plist")
    }
    var projectsArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("projects").appendingPathExtension("plist")
    }
    
    init () {
        loadFiles()
        
        //TODO: save this to the file and load it
        //userDefinedTracking[.positive] = trackingInfo(project: projects[0], desc: "Positive Test")
        //userDefinedTracking[.negative] = trackingInfo(project: projects[1], desc: "Negative Test")
    }
    
    func loadFiles() {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedCredential = try? Data(contentsOf: credentialArchieveURL),
            let decodedCredential = try? propertyListDecoder.decode(credential.self, from: retrievedCredential){
            id = decodedCredential.id
            auth = decodedCredential.auth
            
            print("[Load] id: \(id)")
            print("[Load] auth: \(auth)")
        }
        if let retrievedProjects = try? Data(contentsOf: projectsArchieveURL),
            let decodedProjects = try? propertyListDecoder.decode([projectInfo].self, from: retrievedProjects) {
            print("[Load] Projects retrieved")
            projects = decodedProjects
            for project in projects {
                print("[Load] \(project.pid): \(project.name)")
            }
        }
    }
}

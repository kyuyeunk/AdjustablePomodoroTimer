//
//  TogglController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TogglController {
    let baseInfoURL = URL(string: "https://www.toggl.com/api/v8/me")!
    let projectInfoURL = URL(string: "https://www.toggl.com/api/v8/me?with_related_data=true")!
    let startTimerURL = URL(string: "https://www.toggl.com/api/v8/time_entries/start")!
    let currentTimerURL = URL(string: "https://www.toggl.com/api/v8/time_entries/current")!
    //Get URL that stops the timer. Returns nil if no timer is currently running
    var stopTimerURL: URL? {
        if let entry_id = time_entry_id {
            return URL(string: "https://www.toggl.com/api/v8/time_entries/\(entry_id)/stop")!
        }
        else {
            return nil
        }
    }
    //Use currentTimerURL to fetch time_entry_id
    //Will return nil if no timer is currently running
    var time_entry_id: Int? {
        var entry_id: Int?
        var fetched = false
        getDataFromRequest(requestURL: URLRequest(url: currentTimerURL)) { (data) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let toggl_data = json["data"] as? [String: Any],
                let fetched_id = toggl_data["id"] as? Int {
                print("[Toggl] Fetched time_entry_id: \(fetched_id)")
                entry_id = fetched_id
            }
            else {
                print("[Toggl] Unabled to fetch time_entry_id")
                entry_id = nil
            }
            fetched = true
        }
        
        //Use spinlock to wait for URL request to end
        while(fetched == false) {}
        return entry_id
    }
    
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
        userDefinedTracking[.positive] = trackingInfo(project: projects[0], desc: "Positive Test")
        userDefinedTracking[.negative] = trackingInfo(project: projects[1], desc: "Negative Test")
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
    
    //Send url reqeust from given requestURL
    func getDataFromRequest(requestURL: URLRequest, completion: @escaping (Data) -> Void) {
        let headers = ["Authorization": "Basic \(auth)"]
        
        var myRequestURL = requestURL
        myRequestURL.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: myRequestURL) { (data, response, error) in
            if let data = data {
                completion(data)
            }
            //TODO: Implement error handling
        }
        task.resume()
    }
    
    //Start the timer based on .positive and .negative types
    func startTimer(type: TrackingType) {
        if let info = userDefinedTracking[type] {
            startTimer(pid: info.project.pid, desc: info.desc)
        }
        else {
            print("[Toggl] userDefinedTracking is not set")
        }
    }
    
    //Start the timer with given pid and description
    func startTimer(pid: Int, desc: String) {
        let created_with = "PromodoTimer"
        
        let data = ["time_entry": ["description": desc, "pid": String(pid), "created_with": created_with]]
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        
        var requestURL = URLRequest(url: startTimerURL)
        requestURL.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestURL.httpBody = jsonData
        requestURL.httpMethod = "POST"
        
        getDataFromRequest(requestURL: requestURL) { (data) in
            if let string = String(data: data, encoding: .utf8) {
                print("[Toggl] Timer Started with pid: \(pid) desc: \(desc)")
                print(string)
            }
        }
    }
    
    //Stop currently running timer
    //Do nothing if there's no timer running
    func stopTimer() {
        if let stopTimerURL = stopTimerURL {
            getDataFromRequest(requestURL: URLRequest(url: stopTimerURL)) { (data) in
                if let string = String(data: data, encoding: .utf8) {
                    print("[Toggl] Timer Stopped")
                    print(string)
                }
            }
        }
        else {
            print("[Toggl] Cannot Stop Timer. No Timer Running")
        }
    }
    
    //Fetch api_token from given id/pw and save it to credential.plist
    func setAuth(id: String, pw: String, completion: @escaping (Bool) -> Void) {
        auth = "\(id):\(pw)".toBase64()
        getDataFromRequest(requestURL: URLRequest(url: baseInfoURL)) { (data) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let toggl_data = json["data"] as? [String: Any],
                let api_token = toggl_data["api_token"] as? String {
                
                print(api_token)
                
                self.id = id
                self.auth = "\(api_token):api_token".toBase64()
                
                let cred = credential(id: id, auth: self.auth)
                let propertyListEncoder = PropertyListEncoder()
                let encodedCrednetial = try? propertyListEncoder.encode(cred)
                try? encodedCrednetial?.write(to: self.credentialArchieveURL)
                
                print("[Save] id: \(self.id)")
                print("[Save] auth: \(self.auth)")
                self.setProjectInfo()
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }

    //Fetch list of projects of current user and save it to projects.plist
    func setProjectInfo() {
        getDataFromRequest(requestURL: URLRequest(url: projectInfoURL)) { (data) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let toggl_data = json["data"] as? [String: Any],
                let projects = toggl_data["projects"] as? [[String: Any]] {
                
                self.projects = []
                for project in projects {
                    if project["server_deleted_at"] == nil, let pid = project["id"] as? Int, let name = project["name"] as? String {
                        self.projects.append(projectInfo(pid: pid, name: name))
                    }
                }
                
                let propertyListEncoder = PropertyListEncoder()
                let encodedProjects = try? propertyListEncoder.encode(self.projects)
                try? encodedProjects?.write(to: self.projectsArchieveURL)
                
                print("[Save] Projects saved")
                for project in self.projects {
                    print("[Save] \(project.pid): \(project.name)")
                }
            }
        }
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

enum TrackingType {
    case positive
    case negative
}
// Copied from https://stackoverflow.com/a/35360697
extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

// Copied from book "App Development with Swift"
extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self,
        resolvingAgainstBaseURL: true)
        components?.queryItems = queries.map
        { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}

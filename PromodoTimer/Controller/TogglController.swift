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
    var stopTimerURL: URL {
        return URL(string: "https://www.toggl.com/api/v8/time_entries/\(time_entry_id)/stop")!
    }
    var time_entry_id: Int {
        get {
            var temp: Int?
            getDataFromRequest(requestURL: URLRequest(url: currentTimerURL)) { (data) in
                //TODO: error handling when no timer is running
                //Data will return {"data":null}
                //TODO: parse data to get time_entry_id
                //for now, it is set to predetermined number
                temp = 1476825420
            }
            
            while(temp == nil) {}
            return temp!
        }
    }
    
    var projects: [projectInfo] = []
    var id: String = " "
    var auth: String = ""            //TODO: learn about keychain for better encryption
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var credentialArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("credential").appendingPathExtension("plist")
    }
    var projectsArchieveURL: URL {
        return documentsDirectory.appendingPathComponent("projects").appendingPathExtension("plist")
    }
    
    init () {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedCredential = try? Data(contentsOf: credentialArchieveURL),
            let decodedCredential = try? propertyListDecoder.decode(credential.self, from: retrievedCredential){
            id = decodedCredential.id
            auth = decodedCredential.auth
            
            print("[From directory] id: \(id)")
            print("[From directory] auth: \(auth)")
        }
        if let retrievedProjects = try? Data(contentsOf: projectsArchieveURL),
            let decodedProjects = try? propertyListDecoder.decode([projectInfo].self, from: retrievedProjects) {
            print("[From directory] Projects retrieved")
            projects = decodedProjects
            for project in projects {
                print("[From directory] \(project.pid): \(project.name)")
            }
        }
    }
    
    func getDataFromRequest(requestURL: URLRequest, completion: @escaping (Data) -> Void) {
        let headers = ["Authorization": "Basic \(auth)"]
        
        var myRequestURL = requestURL
        myRequestURL.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: myRequestURL) { (data,
        response, error) in
            if let data = data {
                completion(data)
            }
            //TODO: Implement error handling
        }
        task.resume()
    }
    
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
                print(string)
            }
        }
    }
    
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
                
                print("[To directory] id: \(self.id)")
                print("[To directory] auth: \(self.auth)")
                self.setProjectInfo()
                completion(true)
            }
            else {
                completion(false)
            }
        }

    }

    
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
                
                print("[To directory] Projects saved")
                for project in self.projects {
                    print("[To directory] \(project.pid): \(project.name)")
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

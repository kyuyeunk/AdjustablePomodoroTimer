//
//  TogglController.swift
//  PomodoroTimer
//
//  Created by Kyu Yeun Kim on 2020/03/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TogglController {
    private let baseInfoURL = URL(string: "https://www.toggl.com/api/v8/me")!
    private let projectInfoURL = URL(string: "https://www.toggl.com/api/v8/me?with_related_data=true")!
    private let startTimerURL = URL(string: "https://www.toggl.com/api/v8/time_entries/start")!
    private let currentTimerURL = URL(string: "https://www.toggl.com/api/v8/time_entries/current")!
    //Get URL that stops the timer. Returns nil if no timer is currently running
    private var stopTimerURL: URL? {
        if let entry_id = time_entry_id {
            return URL(string: "https://www.toggl.com/api/v8/time_entries/\(entry_id)/stop")!
        }
        else {
            return nil
        }
    }

    private var time_entry_id: Int?
    
    //Send url reqeust from given requestURL
    private func getDataFromRequest(requestURL: URLRequest, completion: @escaping (Data) -> Void) {
        guard let auth = GlobalVar.settings.togglCredential.auth else {
            print("Error: Authentication has not been set")
            return
        }
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
    func startTimer(type: TimerType) {
        if let info = GlobalVar.settings.currTimer.userDefinedTracking[type] {
            if info.auth == GlobalVar.settings.togglCredential.auth {
                startTimer(pid: info.project.pid, desc: info.desc)
            }
            else {
                print("[Toggl] auth of userDefinedTracking does not match auth of current session")
            }
        }
        else {
            print("[Toggl] userDefinedTracking is not set")
        }
    }
    
    //Start the timer with given pid and description
    private func startTimer(pid: Int, desc: String) {
        let created_with = "PomodoroTimer"
        
        let data = ["time_entry": ["description": desc, "pid": String(pid), "created_with": created_with]]
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        
        var requestURL = URLRequest(url: startTimerURL)
        requestURL.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestURL.httpBody = jsonData
        requestURL.httpMethod = "POST"
        
        getDataFromRequest(requestURL: requestURL) { (data) in
            if let string = String(data: data, encoding: .utf8) {
                print("[Toggl] Timer Started: \(string)")
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let toggl_data = json["data"] as? [String: Any],
                        let entry_id = toggl_data["id"] as? Int {
                
                        self.time_entry_id = entry_id
                        print("[Toggl] time_entry_id set to \(entry_id)")
                }
            }
        }
    }
    
    //Stop currently running timer
    //Do nothing if there's no timer running
    func stopTimer() {
        if let stopTimerURL = stopTimerURL {
            getDataFromRequest(requestURL: URLRequest(url: stopTimerURL)) { (data) in
                if let string = String(data: data, encoding: .utf8) {
                    print("[Toggl] Timer Stopped: \(string)")
                    //print(string)
                    self.time_entry_id = nil
                }
            }
        }
        else {
            print("[Toggl] Cannot Stop Timer. No Timer Running")
        }
    }
    
    //Fetch api_token from given id/pw and save it to credential.plist
    func setAuth(id: String, pw: String, completion: @escaping (Bool) -> Void) {
        GlobalVar.settings.togglCredential.auth = "\(id):\(pw)".toBase64()
        getDataFromRequest(requestURL: URLRequest(url: baseInfoURL)) { (data) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let toggl_data = json["data"] as? [String: Any],
                let api_token = toggl_data["api_token"] as? String {
                
                print(api_token)

                let auth = "\(api_token):api_token".toBase64()
                GlobalVar.settings.setAndSaveAuth(id: id, auth: auth)

                self.setProjectInfo()
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }

    //Fetch list of projects of current user and save it to projects.plist
    private func setProjectInfo() {
        getDataFromRequest(requestURL: URLRequest(url: projectInfoURL)) { (data) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let toggl_data = json["data"] as? [String: Any],
                let projects = toggl_data["projects"] as? [[String: Any]] {
                
                GlobalVar.settings.setAndSaveProjectList(projects: projects)
            }
        }
    }
}

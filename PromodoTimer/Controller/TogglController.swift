//
//  TogglController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TogglController {
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
    
    var id: String = " "
    var auth: String = ""            //TODO: learn about keychain for better encryption
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var archiveURL: URL {
        return documentsDirectory.appendingPathComponent("credential").appendingPathExtension("plist")
    }
    
    init () {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedData = try? Data(contentsOf: archiveURL),
            let decodedCredential = try? propertyListDecoder.decode(credential.self, from: retrievedData){
            id = decodedCredential.id
            auth = decodedCredential.auth
            
            print("Read id \(id)")
            print("Read auth \(auth)")
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
    
    func startTimer() {
        let pid = 89341778      //Example input
        let desc = "Working"    //Example input
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
    
    func setAuth(id: String, pw: String) {
        self.id = id
        auth = "\(id):\(pw)".toBase64()
        print("Set auth to \(auth)")
        
        try? auth.write(to: archiveURL, atomically: false, encoding: .utf8)
        
        let cred = credential(id: id, auth: auth)
        let propertyListEncoder = PropertyListEncoder()
        let encodedCrednetial = try? propertyListEncoder.encode(cred)
        try? encodedCrednetial?.write(to: archiveURL)
        
    }

    
    func getProjectInfo() {
        getDataFromRequest(requestURL: URLRequest(url: projectInfoURL)) { (data) in
            if let string = String(data: data, encoding: .utf8) {
                print(string)
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

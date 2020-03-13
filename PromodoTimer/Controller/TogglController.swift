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
        get {
            let time_id = time_entry_id ?? {
                set_time_entry_id()
                while(true) {
                    if let val = time_entry_id {
                        return val
                    }
                }
            }()
    
            return URL(string: "https://www.toggl.com/api/v8/time_entries/\(time_id)/stop")!
        }
    }
    var time_entry_id: Int?
    func set_time_entry_id(){
        getDataFromRequest(url: currentTimerURL) { (data) in
            //TODO: parse data to get time_entry_id
            //for now, it is set to predetermined number
            self.time_entry_id = 1476825420
        }
    }
    
    let idpwFile = "idpw.txt"   //TODO: FOR TESTING PURPOSE ONLY
    var id: String = ""              //TODO: DO NOT STORE USER DATA IN PLAIN TEXT
    var pw: String = ""              //TODO: DO NOT STORE USER DATA IN PLAIN TEXT
    var auth: String {
        get {
            return "\(self.id):\(self.pw)".toBase64()
        }
    }
    
    init () {
        getidpw()
    }
    
    func getDataFromRequest(url: URL, completion: @escaping (Data) -> Void) {
        let headers = ["Authorization": "Basic \(auth)"]
        
        var requestURL = URLRequest(url: url)
        requestURL.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data,
        response, error) in
            if let data = data {
                completion(data)
            }
        }
        task.resume()
    }
    
    func getidpw() {
        if let filepath = Bundle.main.path(forResource: idpwFile, ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)
                let splitted = contents.components(separatedBy: " ")
                
                id = splitted[0]
                pw = String(splitted[1].dropLast())
                print("Toggl id: \(id), pw: \(pw)")
            }
            catch {
                
            }
        }
    }
    
    func getProjectInfo() {
        getDataFromRequest(url: projectInfoURL) { (data) in
            if let string = String(data: data, encoding: .utf8) {
                print(string)
            }
        }
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

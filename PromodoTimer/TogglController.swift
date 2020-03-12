//
//  TogglController.swift
//  PromodoTimer
//
//  Created by Kyu Yeun Kim on 2020/03/12.
//  Copyright © 2020 Kyu Yeun Kim. All rights reserved.
//

import Foundation

class TogglController {
    let baseURL = URL(string: "https://www.toggl.com/api/v8/me")!
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
    
    func getidpw() {
        id = "test"
        if let filepath = Bundle.main.path(forResource: idpwFile, ofType: nil) {
            do {
                let contents = try String(contentsOfFile: filepath)
                let splitted = contents.components(separatedBy: " ")
                
                id = splitted[0]
                pw = String(splitted[1].dropLast())
                print("id: \(id), pw: \(pw)")
            }
            catch {
                
            }
        }
    }
    
    func getProjects() {
        let headers = ["Authorization": "Basic \(auth)"]
        
        var requestURL = URLRequest(url:baseURL)
        requestURL.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: requestURL) { (data,
        response, error) in
            if let data = data,
                let string = String(data: data, encoding: .utf8) {
                
                print(string)
            }
        }
        task.resume()
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

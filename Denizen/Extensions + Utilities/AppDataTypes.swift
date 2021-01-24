//
//  AppDataTypes.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import Foundation

// MARK:- Web service manager

struct WebServiceManager {
//    var urlString: String
//    var parameters: [String: String]?
//    
//    func makeAPIRequest(){
//
//    }
    
    //Send Request with ResultType<Success, Error>
    func sendRequest(_ url: String, parameters: [String: String]? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        if let parameters = parameters {
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
        }

        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  (200 ..< 300) ~= response.statusCode,
                  error == nil else {
                completion(nil, error)
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completion(responseObject, nil)
        }
        task.resume()
    }
}



//sendRequest("someurl", parameters: ["foo": "bar"]) { responseObject, error in
//    guard let responseObject = responseObject, error == nil else {
//        print(error ?? "Unknown error")
//        return
//    }
//
//    // use `responseObject` here
//}

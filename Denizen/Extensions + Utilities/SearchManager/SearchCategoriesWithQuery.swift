//
//  SearchCategoriesWithQuery.swift
//  Denizen
//
//  Created by J C on 2021-01-27.
//

import Foundation

enum SearchCategoriesWithQuery: SearchManager {
    case tag(String)
    case tagPackageShow
    
    var actionType: ActionType {
        switch self {
            case .tag:
                return .packageSearch
            case .tagPackageShow:
                return .packageShow
        }
    }
    
    var queryKey: QueryKey {
        switch self {
            case .tag:
                return .fq
            case .tagPackageShow:
                return .id
        }
    }
    
    var urlWithQuery: String {
        switch self {
            case .tag:
                return URLScheme.baseURL + actionType.rawValue
            case .tagPackageShow:
                return URLScheme.baseURL + actionType.rawValue
        }
    }
    
    var filterKey: QueryFilter {
        switch self {
            case .tag:
                return .tags
            default:
                return .none
        }
    }
    
    var filterItem: String {
        switch self {
            case .tag(let title):
                return self.filterKey.rawValue + ":" + title
            default:
                return ""
        }
    }
    
    var parameters: [QueryKey: String]? {
        switch self {
            case .tag:
                return [self.queryKey: self.filterItem]
            default:
                return nil
        }
    }
    
    
    
    func fetchAPI(url: String, parameters: [QueryKey: String]?,  completion: @escaping ([String: Any]?, Error?) -> Void) {
        print("parameters", parameters)
        var components = URLComponents(string: url)!
        if let parameters = parameters {
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key.rawValue, value: value)
            }
        }
        
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        print(components.url)

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
    
    func fetchAPIWithString(url: String, parameters: [String]?,  completion: @escaping ([String: Any]?, Error?) -> Void) {
        print("parameters", parameters)
        var components = URLComponents(string: url)!
        if let parameters = parameters {
            components.queryItems = parameters.map { (param) in
                URLQueryItem(name: self.queryKey.rawValue, value: param)
            }
        }
        
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        print(components.url)
        
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

//
//  SearchCategories.swift
//  Denizen
//
//  Created by J C on 2021-01-26.
//

import Foundation

// MARK: - SearchCategories
/// SearchResultsController, WebServiceManager

enum SearchCategories: String, CaseIterable {
    case tags = "Tags"
    case packages = "Packages"
    case recentlyChanged = "Recently Changed"
    case qualityScores = "Quality Scores"

    var actionType: ActionType {
        switch self {
            case .tags:
                return .tagShow
            case .packages:
                return .datastoreSearch
            case .recentlyChanged:
                return .packageShow
            case .qualityScores:
                return .packageShow
        }
    }
    
    var queryKey: QueryKey {
        switch self {
            case .tags:
                return .id
            case .packages:
                return .id
            case .recentlyChanged:
                return .id
            case .qualityScores:
                return .id
        }
    }
    
    var url: String {
        switch self {
            case .tags:
                return URLScheme.baseURL + URLScheme.Subdomain.tags
            case .packages:
                return URLScheme.baseURL + URLScheme.Subdomain.packages
            case .recentlyChanged:
                return URLScheme.baseURL + URLScheme.Subdomain.recentlyChanged
            case .qualityScores:
                return URLScheme.baseURL + URLScheme.Subdomain.qualityScores + URLScheme.Subdomain.id.qualityScoresId
        }
    }
    
    var urlWithQuery: String {
        switch self {
            case .tags:
                return URLScheme.baseURL + actionType.rawValue
            case .packages:
                return URLScheme.baseURL + actionType.rawValue
            case .recentlyChanged:
                return URLScheme.baseURL + actionType.rawValue
            case .qualityScores:
                return URLScheme.baseURL + actionType.rawValue
        }
    }
    
    func fetchAPI(url: String, parameters: [QueryKey: String]?,  completion: @escaping ([String: Any]?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        if let parameters = parameters {
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key.rawValue, value: value)
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

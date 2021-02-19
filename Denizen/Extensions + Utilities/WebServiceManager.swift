//
//  WebServiceManager.swift
//  Denizen
//
//  Created by J C on 2021-01-24.
//

import Foundation

class WebServiceManager {
    static let shared = WebServiceManager()
    let baseURL = URLScheme.baseURL
    let defaults = UserDefaults.standard
    // rules
    // 1. if there is fq already (?fq=), fq cannot be repeated. "+" has to be used instead. For example, if fq exists already, you cannot have &sort= in the middle and then another fq at the end
    // 2. if q is used, then fq can be added at the end as such https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?q=Environment,poverty&fq=dataset_category:%22Document%22
    // 3. can be combined with facet field https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?facet.field=[%22civic_issues%22]&rows=0&fq=dataset_category:%22Document%22
    //    except &rows=0 doesn't have any dataset category so without the row filter, it works
    // 4. cannot be combined with datastore_search/?id=lksdjfks
    // 5. sort requires & as such &sort=metadata_modified%20asc
    // 6. can be combined with package_show as such https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=735c2177-513b-49dd-b4bc-6435d6a80efe&fq=formats:%22SHP,XLSX%22&sort=metadata_modified%20asc
    // 7. cannot be combined with json formatted lists like package_list or tag_list or recently_changed_packages_activity_list
    // 8. works with topics which is https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?facet.field=%5B%22topics%22%5D&fq=dataset_category:%22Document%22
    // summary:
    // package_search, package_show work
    // datastore_search or any lists don't work
    
    
    func getURL(urlString: String, parameterDict: [String: String]?, filters: [Filter]?) -> URL? {
        guard var components = URLComponents(string: urlString) else { return nil }
        var queryItems = [URLQueryItem]()
        
        if let parameterDict = parameterDict {
            var hasFq = false
            for (key, value) in parameterDict {
                // if the parameter has fq already, add the filters to it
                if key == Query.Key.fq {
                    hasFq = true
                    var queryString = ""
                    queryString += value
                    filters?.forEach({ (filter) in
                        if let url = filter.url {
                            queryString += "+" + url
                        }
                    })
                    queryItems.append(URLQueryItem(name: key, value: queryString))
                } else {
                    // none fq related paramters
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
            
            // the parameter has no fq
            if hasFq == false {
                var queryString: String!
                filters?.forEach({ (filter) in
                    // if it's a first query filter
                    if queryString == nil {
                        if let url = filter.url {
                            queryString = url
                            // sorting doesn't need fq
                            if filter.title == .orderBy {
                                queryItems.append(URLQueryItem(name: Query.Key.sort, value: queryString))
                            } else {
                                queryItems.append(URLQueryItem(name: Query.Key.fq, value: queryString))
                            }
                        }
                    } else {
                        if let url = filter.url {
                            // fq=dataset_category:"Map"&*=dataset_category:"Document" <- "&*= gets replaced by +
                            // sorting doesn't need fq
                            if filter.title == .orderBy {
                                queryItems.append(URLQueryItem(name: Query.Key.sort, value: url))
                            } else {
                                queryItems.append(URLQueryItem(name: "*", value: url))
                            }
                        }
                    }
                })
            }
        }
        
        components.queryItems = queryItems
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "&*=", with: "+")
        return components.url
    }
    
    func sendRequest(urlString: String, parameters: [String: String]?, filters: [Filter]? = nil, completion: @escaping ([String: Any]?, Error?) -> Void) {
        if let url = getURL(urlString: urlString, parameterDict: parameters, filters: filters) {
            print(url)
            let urlDict = ["url": url]
            NotificationCenter.default.post(name:.urlFetched, object: nil, userInfo: urlDict)
            let request = URLRequest(url: url)
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
}

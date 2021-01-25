//
//  AsyncFetcherOperation.swift
//  Denizen
//
//  Created by J C on 2021-01-24.
//

import Foundation

class AsyncFetcherOperation: Operation {
    // MARK:- Properties
    
    let identifier: UUID
    var fetchedData: [FetchedData]?
    
    // MARK:- Initialization
    
    init(identifier: UUID) {
        self.identifier = identifier
    }
}

// MARK:- Operation overrides

extension AsyncFetcherOperation {
    override func main() {
        guard !isCancelled else { return }
        configureAPIRequest()
 
    }
    
    /// Create an API request
    /// - Parameter None
    /// - Throws None
    /// - Returns Void
    /// - Create an API request to the Catalogue Quality Scores
    /// https://open.toronto.ca/dataset/catalogue-quality-scores/
    func configureAPIRequest(offsetBy: Int = 0) {
        //        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search?id=7b2830a7-1483-451f-8681-ef4942eedc34"
        //        let paramters = ["id": "22f223e7-73f7-4842-935c-80a0ba5c3e5b", "limit": "10"]
        let OFFSET_CONSTANT = 20
        print("total", String(OFFSET_CONSTANT * offsetBy))
        //        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/recently_changed_packages_activity_list"
        //        let parameters: [String: String] = ["limit": "20", "offset": String(OFFSET_CONSTANT * offsetBy)]
        
        //        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=473def30-1c87-45f1-95c4-06b9bf693fec"
        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search"
        //        var parameters: [String: String]?
        let parameters: [String: String] = ["id": "22f223e7-73f7-4842-935c-80a0ba5c3e5b", "limit": "5", "offset": String(OFFSET_CONSTANT * offsetBy)]
        
        let webServiceManager = WebServiceManager()
        webServiceManager.sendRequest(urlString, parameters: parameters) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            //            print(responseObject)
            //            if let result = responseObject["result"] as? [String: Any] {
            //                print("result", result)
            //            }

            //            latest updates
            //            if let result = responseObject["result"] as? [[String: Any]] {
            //                result.forEach { (package) in
            //                    if let data = package["data"] as? [String: Any], let package = data["package"] as? [String: Any], let title = package["title"] as? String {
            //                        self.snapshot.appendItems([Package(title: title)])
            //                    }
            //                }
            //            }
            
            //              tag_list?
            //            if let result = responseObject["result"] as? [String: Any] {
            //                // parse all the fields
            //                if let fields = result["fields"] as? [[String: Any]] {
            //
            //                    fields.forEach { (field) in
            //                        let f = Field(id: field["id"] as? String, info: field["info"] as? [String: String], type: field["type"] as? String)
            //                        self.fieldsArr.append(f)
            //                    }
            //                }
            //
            //                // parse the content of the API fetch to be displayed
            
            if let result = responseObject["result"] as? [String: Any],  let finalResult = result["records"] as? [[String: Any]] {
                finalResult.forEach { (catalogue) in
                    if let package = catalogue["package"] as? String {
                        self.fetchedData?.append(CatalogueQualityScores(package: package))
                    }
                }
            }
        }
    }
}

//
//  ViewController + ResultsUpdate.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//
/*
 Abstract:
    UISearchResultsUpdating protocol is a set of methods that let you update search results based on information the user enters into the search bar.
    It makes use of two things:
        1) the text from the search bar text field
        2) the token(s) from the search bar text field
    Given these two, the search results are updated on SearchResultsController.
 */

import UIKit

extension ViewController: UISearchResultsUpdating {
    
    // MARK:- updateSearchResults
    // Called when the search bar's text has changed or when the search bar becomes first responder.
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        // fetch the API from one of SearchCategories as long as a token is selected and the text field is empty
        if text.isEmpty, !searchController.searchBar.searchTextField.tokens.isEmpty  {
            suggestArray.removeAll()

            let searchTextField = searchController.searchBar.searchTextField
            let searchToken = searchTextField.tokens[searchTextField.tokens.count - 1]
            
            if let searchTokenValue = searchToken.representedObject as? SearchCategories {
                fetchAndParse(suggestedSearch: searchTokenValue)
            }
        }else {
            // now that we have the list from the selected token, we can further filter the list
            var filtered = suggestArray
            
            // Strip out all the leading and trailing spaces.
            let whitespaceCharacterSet = CharacterSet.whitespaces
            let strippedString = text.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
            let searchItems = strippedString.components(separatedBy: " ") as [String]
            
            // Filter results down by matching words. Can include multiple properties if the data type has them.
            var curTerm = searchItems[0]
            var idx = 0
            while curTerm != "" {
                filtered = filtered.filter { $0.title.lowercased().contains(curTerm) }
                idx += 1
                curTerm = (idx < searchItems.count) ? searchItems[idx] : ""
            }
            
            // Apply the filtered results to the search results table.
            loadSearchControllerData(with: filtered)
        }
    }
    
    // 1. .suggested: .tags -> .additionalSuggest
    // 2. .additionalSuggest: tag(title) -> .none
    // 3. .none: didSelectItem -> ItemDetail
    
    // MARK:- fetchAndParse
    
    func fetchAndParse(suggestedSearch: SearchCategories) {
        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        self.suggestArray.removeAll()
        
        var urlString: String!
        var parameters: [String: String]!

        switch suggestedSearch {
            case .tags:
                urlString = URLScheme.baseURL + URLScheme.Subdomain.tags
                fetchAPI(urlString: urlString, parameters: parameters, suggestedSearch: suggestedSearch)
            case .packages:
                urlString = URLScheme.baseURL + URLScheme.Subdomain.packages
                fetchAPI(urlString: urlString, parameters: parameters, suggestedSearch: suggestedSearch)
            case .recentlyChanged:
                urlString = URLScheme.baseURL + URLScheme.Subdomain.recentlyChanged
                fetchAPI(urlString: urlString, parameters: parameters, suggestedSearch: suggestedSearch)
            case .qualityScores:
                urlString = URLScheme.baseURL + URLScheme.Subdomain.qualityScores + URLScheme.Subdomain.id.qualityScoresId
                fetchAPI(urlString: urlString, parameters: parameters, suggestedSearch: suggestedSearch)
            case .tag(let title):
                urlString = URLScheme.baseURL + Query.ActionType.packageSearch
                parameters = [Query.Key.fq: Query.Filter.tags + ":" + title]
                
                fetchAPI(urlString: urlString, parameters: parameters, suggestedSearch: suggestedSearch)
            case .topics:
                urlString = URLScheme.baseURL + Query.ActionType.packageSearch
                parameters = [Query.Key.facetField: "[\u{22}topics\u{22}]"]
//                parameters = [Query.Key.facetField: "[\u{22}topics\u{22}]", Query.Key.rows: "0"]
                fetchAPI(urlString: urlString, parameters: parameters, filters: filters, suggestedSearch: suggestedSearch)
            case .topic(let title):
                urlString = URLScheme.baseURL + Query.ActionType.packageSearch
                parameters = [Query.Key.q: title]
                fetchAPI(urlString: urlString, parameters: parameters, filters: filters, suggestedSearch: suggestedSearch)
            case .civicIssues:
                urlString = URLScheme.baseURL + Query.ActionType.packageSearch
//                parameters = [Query.Key.facetField: "[\u{22}civic_issues\u{22}]", Query.Key.rows: "0"]
                parameters = [Query.Key.facetField: "[\u{22}civic_issues\u{22}]"]
                fetchAPI(urlString: urlString, parameters: parameters, filters: filters, suggestedSearch: suggestedSearch)
            default:
                break
        }
    }
    
    func fetchAPI(urlString: String, parameters: [String: String]?, filters: [Filter]? = nil, suggestedSearch: SearchCategories) {
        WebServiceManager.shared.sendRequest(urlString: urlString, parameters: parameters, filters: filters) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print("fetch and parse error",error?.localizedDescription ?? "Unknown error")
                self.showAlertController(error: error)
                return
            }
            
            switch suggestedSearch {
                case .tags:
                    if let results = responseObject["result"] as? [String] {
                        let fetchedDataArr = results.map { FetchedData(title: $0, searchCategories: suggestedSearch, parameters: [Query.Key.fq: $0])}
                        self.suggestArray += fetchedDataArr
                    }
                    self.loadSearchControllerData(with: self.suggestArray)
                    
                    // when the token is deleted by backspace, the no row is selected, which means there is no change for the showSuggestedSearches to be toggled.
                    DispatchQueue.main.async {
                        self.searchResultsController.showSuggestedSearches = .additionalSuggest
                    }
                case .packages:
                    if let results = responseObject["result"] as? [String] {
                        let fetchedDataArr = results.map { FetchedData(title: $0, searchCategories: suggestedSearch, parameters: [Query.Key.fq: "name:" + $0])}
                        self.suggestArray += fetchedDataArr
                    }
                    self.loadSearchControllerData(with: self.suggestArray)
                case .recentlyChanged:
                    if let results = responseObject["result"] as? [[String: Any]] {
                        results.forEach { (package) in
                            if let data = package["data"] as? [String: Any],
                               let package = data["package"] as? [String: Any],
                               let title = package["title"] as? String,
                               let id = package["id"] as? String {
                                let parameters: [String: String] = [Query.Key.id: id]
                                let fetchedData = FetchedData(title: title, searchCategories: suggestedSearch, parameters: parameters)
                                self.suggestArray.append(fetchedData)
                            }
                        }
                    }
                    self.loadSearchControllerData(with: self.suggestArray)
                case .qualityScores:
                    if let result = responseObject["result"] as? [String: Any], let records = result["records"] as? [[String: Any]] {
                        records.forEach { (catalogue) in
                            if let package = catalogue["package"] as? String {
                                let fetchedData = FetchedData(title: package, searchCategories: suggestedSearch, parameters: [Query.Key.id: package])
                                self.suggestArray.append(fetchedData)
                            }
                        }
                    }
                    self.loadSearchControllerData(with: self.suggestArray)
                case .tag(_), .topic(_):
                    if let result = responseObject["result"] as? [String: Any], let results = result["results"] as? [[String: Any]] {
                        results.forEach { (item) in
                            if let title = item["title"] as? String, let id = item["id"] as? String {
                                // https:/ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=7e038ff9-b616-4070-9753-6f493b2cdbb0
                                let fetchedData = FetchedData(title: title, searchCategories: suggestedSearch, parameters: [Query.Key.id: id])
                                self.suggestArray.append(fetchedData)
                            }
                        }
                        self.loadSearchControllerData(with: self.suggestArray)
                    }
                case .topics:
                    if let result = responseObject["result"] as? [String: Any], let facets = result["facets"] as? [String: Any], let topics = facets["topics"] as? [String: Any] {
                        topics.forEach { (item) in
                            let fetchedData = FetchedData(title: item.key, searchCategories: suggestedSearch, parameters: [Query.Key.fq: "topics:" + "\"" + item.key + "\""])
                            self.suggestArray.append(fetchedData)
                        }
                    }
                    self.loadSearchControllerData(with: self.suggestArray)
                    
                    // when the token is deleted by backspace, the no row is selected, which means there is no change for the showSuggestedSearches to be toggled.
                    DispatchQueue.main.async {
                        self.searchResultsController.showSuggestedSearches = .additionalSuggest
                    }
                case .civicIssues:
                    
                    if let result = responseObject["result"] as? [String: Any], let facets = result["facets"] as? [String: Any], let civicIssues = facets["civic_issues"] as? [String: Any] {
                        civicIssues.forEach { (item) in
                            let fetchedData = FetchedData(title: item.key, searchCategories: suggestedSearch, parameters: [Query.Key.fq: "civic_issues:" + "\"" + item.key + "\""])
                            self.suggestArray.append(fetchedData)
                        }
                    }
                    self.loadSearchControllerData(with: self.suggestArray)
                default:
                    break
            }
        }
    }
    
    // MARK: - Alert controller
    
    func showAlertController(error: Error?) {
        DispatchQueue.main.async {
            self.navigationController?.activityStopAnimating()
            let alertController = UIAlertController(title: "Network Error", message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                if let searchField = self.navigationItem.searchController?.searchBar.searchTextField {
                    var count = searchField.tokens.count
                    while count > 0 {
                        searchField.removeToken(at: count - 1)
                        count -= 1
                    }
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK:- loadSearchControllerData
    
    /// Loads the search results controller
    /// - Parameter `[Stirng]` The array of fetched data from the API request
    /// - Parameter `SearchCategories`  The enum type is passed to the search results controller for didSelectRowAt. It's required for ItemDetailViewcontroller to make an appropriate API request.
    /// - Throws None
    /// - Returns `Void`
    /// - Loads the search results controller with the data fetched from the API request as well as the SearchCategories.
    
    func loadSearchControllerData(with fetchedDataArr: [FetchedData]) {
        DispatchQueue.main.async {
            self.navigationController?.activityStopAnimating()
            self.searchResultsController.fetchedDataArr = fetchedDataArr
            self.searchResultsController.tableView.reloadData()
        }
        
//        DispatchQueue.main.async {
//            self.navigationController?.activityStopAnimating()
//            self.searchResultDetailVC?.fetchedDataArr = fetchedDataArr
//            self.searchResultDetailVC?.tableView.reloadData()
//        }
    }
}

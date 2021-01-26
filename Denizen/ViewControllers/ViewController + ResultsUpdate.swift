//
//  ViewController + ResultsUpdate.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//

import UIKit

extension ViewController: UISearchResultsUpdating {
    
    // Called when the search bar's text has changed or when the search bar becomes first responder.
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        // fetch the API from one of SearchCategories as long as a token is selected and the text field is empty
        if text.isEmpty, !searchController.searchBar.searchTextField.tokens.isEmpty  {
            let searchToken = searchController.searchBar.searchTextField.tokens[0]
            if let searchTokenValue = searchToken.representedObject as? NSNumber {
                let suggestedSearch = SearchCategories.allCases[searchTokenValue.intValue]
                
                WebServiceManager.shared.sendRequest(with: suggestedSearch) { (responseObject, error) in
                    guard let responseObject = responseObject, error == nil else {
                        print(error?.localizedDescription ?? "Unknown error")
                        return
                    }
                    
                    switch suggestedSearch {
                        case .tags:
                            if let results = responseObject["result"] as? [String] {
                                self.suggestArray += results
                                self.loadSearchControllerData(with: self.suggestArray)
                            }
                        case .packages:
                            if let results = responseObject["result"] as? [String] {
                                self.suggestArray += results
                                self.loadSearchControllerData(with: self.suggestArray)
                            }
                        case .recentlyChanged:
                            if let results = responseObject["result"] as? [[String: Any]] {
                                let parsed = results.compactMap { (package) -> String? in
                                    if let data = package["data"] as? [String: Any], let package = data["package"] as? [String: Any], let title = package["title"] as? String {
                                        return title
                                    }
                                    return nil
                                }
                                self.suggestArray += parsed
                                self.loadSearchControllerData(with: self.suggestArray)
                            }
                        case .qualityScores:
                            print(responseObject)
                    }
                }
            }
        } else {
            var filtered = suggestArray

            // Strip out all the leading and trailing spaces.
            let whitespaceCharacterSet = CharacterSet.whitespaces
            let strippedString = text.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
            let searchItems = strippedString.components(separatedBy: " ") as [String]
            
            // Filter results down by matching words. Can include multiple properties if the data type has them.
            var curTerm = searchItems[0]
            var idx = 0
            while curTerm != "" {
                filtered = filtered.filter { $0.lowercased().contains(curTerm) }
                idx += 1
                curTerm = (idx < searchItems.count) ? searchItems[idx] : ""
            }
            
            // Apply the filtered results to the search results table.
            loadSearchControllerData(with: filtered)
        }
    }
    
    func fetchAPI(for suggestedSearch: SearchCategories, with parameters: [String: String]?) {
        WebServiceManager.shared.sendRequest(with: suggestedSearch) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
        }
    }
    
    func loadSearchControllerData(with stringArr: [String]) {
        DispatchQueue.main.async {
            if let searchResultsController = self.searchController.searchResultsController as? SearchResultsController {
                searchResultsController.items = stringArr
                searchResultsController.tableView.reloadData()
            }
        }
    }
}


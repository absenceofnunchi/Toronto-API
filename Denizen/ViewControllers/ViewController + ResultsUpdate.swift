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
            let searchTextField = searchController.searchBar.searchTextField
            let searchToken = searchTextField.tokens[searchTextField.tokens.count - 1]
            if let searchTokenValue = searchToken.representedObject as? NSNumber {
                let suggestedSearch = SearchCategories.allCases[searchTokenValue.intValue]
                fetchAndParse(suggestedSearch: suggestedSearch)
                print("1 fetch and parse")
            } else {
                print("2 fetch and parse")

            }
        } else {
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
    
    // MARK:- fetchAndParse
    func fetchAndParse(suggestedSearch: SearchCategories) {
        suggestedSearch.fetchAPI(url: suggestedSearch.url , parameters: nil) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }
            
            switch suggestedSearch {
                case .tags:
                    if let results = responseObject["result"] as? [String] {
                        let fetchedDataArr = results.map { FetchedData(title: $0, searchCategories: suggestedSearch, parameters: [suggestedSearch.queryKey: $0])}
                        self.suggestArray += fetchedDataArr
                        self.loadSearchControllerData(with: self.suggestArray)
                    }
                case .packages:
                    if let results = responseObject["result"] as? [String] {
                        let fetchedDataArr = results.map { FetchedData(title: $0, searchCategories: suggestedSearch, parameters: [suggestedSearch.queryKey: $0])}
                        self.suggestArray += fetchedDataArr
                        self.loadSearchControllerData(with: self.suggestArray)
                    }
                case .recentlyChanged:
                    if let results = responseObject["result"] as? [[String: Any]] {
                        results.forEach { (package) in
                            if let data = package["data"] as? [String: Any],
                               let package = data["package"] as? [String: Any],
                               let title = package["title"] as? String,
                               let id = package["id"] as? String {
                                let parameters: [QueryKey: String] = [suggestedSearch.queryKey: id]
                                let fetchedData = FetchedData(title: title, searchCategories: suggestedSearch, parameters: parameters)
                                self.suggestArray.append(fetchedData)
                            }
                        }
                        self.loadSearchControllerData(with: self.suggestArray)
                    }
                case .qualityScores:
                    if let result = responseObject["result"] as? [String: Any], let records = result["records"] as? [[String: Any]] {
                        records.forEach { (catalogue) in
                            if let package = catalogue["package"] as? String {
                                let fetchedData = FetchedData(title: package, searchCategories: suggestedSearch, parameters: [suggestedSearch.queryKey: package])
                                self.suggestArray.append(fetchedData)
                            }
                        }
                        self.loadSearchControllerData(with: self.suggestArray)
                    }
            }
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
            if let searchResultsController = self.searchController.searchResultsController as? SearchResultsController {
                searchResultsController.fetchedDataArr = fetchedDataArr
                searchResultsController.tableView.reloadData()
            }
        }
    }
}

//You will need to contact MPAC directly for data that you may perceive as missing. [MPAC website](https://www.mpac.ca/).
//, "name": address-points-municipal-toronto-one-address-repository, "metadata_modified": 2021-01-26T23:15:37.093942, "private": 0, "state": active, "revision_id": 2041b023-2176-4bde-aa8f-7d9e0edca71a, "title": Address Points (Municipal) - Toronto One Address Repository, "url": <null>, "license_id": open-government-licence-toronto, "version": <null>, "metadata_created": 2019-07-23T16:30:45.457004, "id": abedd8bc-e3dd-4d45-8e69-79165a76e4fa, "owner_org": 95a064ae-77e8-4ef0-a4e3-4e2d43e1f066, "type": dataset, "author": <null>]
//package ["author_email": <null>, "maintainer_email": <null>, "creator_user_id": 150d5301-86ec-44a3-a070-50f2cea839c9, "maintainer": <null>, "notes":

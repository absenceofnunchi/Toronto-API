//
//  ViewController + SearchBar.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//
/*
 Abstract:
 defines the search controller, which involves,
    1. set the apepearance of the search bar and the search text field
    2. set the search results controller
    3. define what happens when the user taps on the items from search results controller
 */

import UIKit

// MARK: - Search results controller

extension ViewController {
    
    // configure search controller
    func configureSearchController() {
        searchResultsController = SearchResultsController()
        searchResultsController.suggestedSearchDelegate = self // So we can be notified when a suggested search token is selected.
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.isActive = true
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
}

// MARK:- Search bar

extension ViewController: UISearchBarDelegate {
    
    // search bar and search field appearance
    func configureSearchBar() {
        // search bar attributes
        let searchBar = searchController!.searchBar
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.sizeToFit()
        searchBar.tintColor = .black
        searchBar.searchBarStyle = .minimal
        
//        // set the search bar height
        let size = CGSize(width: 1, height: 50)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        let image = renderer.image { (_) in
//            UIColor.white.setFill()
//            let rect = UIBezierPath(rect: CGRect(origin: .zero, size: size))
//            rect.fill()
//        }
//        searchBar.setSearchFieldBackgroundImage(image, for: .normal)
        
        // search text field attributes
        let searchTextField = searchBar.searchTextField
        searchTextField.borderStyle = .roundedRect
        searchTextField.layer.cornerRadius = 8
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
        searchTextField.frame = CGRect(origin: .zero, size: size)
        
        // cancel button location adjustment
        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        cancelButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: .default)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            setToSuggestedSearches()
        } else {
            searchResultsController.showSuggestedSearches = .none
        }
    }
    
    func setToSuggestedSearches() {

        // Show suggested searches only if we don't have a search token in the search field.
        if searchController.searchBar.searchTextField.tokens.isEmpty {
            searchResultsController.showSuggestedSearches = .suggested
            
            // We are no longer interested in cell navigating, since we are now showing the suggested searches.
            searchResultsController.tableView.delegate = searchResultsController
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // User tapped the Done button in the keyboard.
        searchController.dismiss(animated: true, completion: nil)
        searchBar.text = ""
    }
}

// MARK: - UISearchControllerDelegate
// Use these delegate functions for additional control over the search controller.

extension ViewController: UISearchControllerDelegate {
    
    // We are being asked to present the search controller, so from the start - show suggested searches.
    func presentSearchController(_ searchController: UISearchController) {
        searchController.showsSearchResultsController = true
        setToSuggestedSearches()
    }
}

// MARK:- SuggestedSearch protocol conformance

extension ViewController: SuggestedSearch {
    // SearchResultsController selected a suggested search, so we need to apply the search token.
    func didSelectSuggestedSearch(token: UISearchToken) {
        if let searchField = navigationItem.searchController?.searchBar.searchTextField {
            searchField.insertToken(token, at: searchField.tokens.count > 0 ? searchField.tokens.count : 0)
            
            if let searchTokenValue = token.representedObject as? SearchCategories {
                switch searchTokenValue {
                    case .tags:
                        searchResultsController.showSuggestedSearches = .additionalSuggest
                    case .tag(_):
                        if searchField.tokens.count == 2 {
                            searchResultsController.showSuggestedSearches = .none
                        }
                    case .topics:
                        searchResultsController.showSuggestedSearches = .additionalSuggest
                    case .topic(_):
                        searchResultsController.showSuggestedSearches = .none
                    default:
                        searchResultsController.showSuggestedSearches = .none
                }
            }
            // Update the search query with the newly inserted token
            updateSearchResults(for: searchController!)
        }
    }
    
    // SearchResultscontroller selected an item so navigate to that item
    func didSelectItem(fetchedData: FetchedData) {
        // Set up the detail view controller to show
        let itemDetailVC = ItemDetailViewController()
        itemDetailVC.fetchedData = fetchedData
        navigationController?.pushViewController(itemDetailVC, animated: true)
    }
}

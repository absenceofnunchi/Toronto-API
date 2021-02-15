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
        
        // search text field attributes
        let searchTextField = searchBar.searchTextField
        searchTextField.borderStyle = .roundedRect
        searchTextField.layer.cornerRadius = 8
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
        let size = CGSize(width: 1, height: 50)
        searchTextField.frame = CGRect(origin: .zero, size: size)
        
        let filterButton = UIButton.systemButton(with: UIImage(systemName: "line.horizontal.3.decrease.circle")!, target: self, action: #selector(leftViewButtonHandler))
        filterButton.frame = CGRect(x: 0, y: 0, width: 50, height: searchTextField.frame.height)
        filterButton.backgroundColor = .clear
        searchTextField.leftView = filterButton
        searchTextField.leftViewMode = .always
        
        // cancel button location adjustment
        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        cancelButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: .default)
    }
    
    @objc func leftViewButtonHandler() {
        //        let text = searchController.searchBar.searchTextField.text
        let filterViewController = FilterViewController(style: .insetGrouped)
        filterViewController.delegate = self
        let navController = UINavigationController(rootViewController: filterViewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            setToSuggestedSearches()
        } else if searchBar.searchTextField.tokens.isEmpty {
            searchResultsController.showSuggestedSearches = .none
        }
    }
    
    func setToSuggestedSearches() {
        // Show suggested searches only if we don't have a search token in the search field.
        if searchController.searchBar.searchTextField.tokens.isEmpty {
            searchResultsController.showSuggestedSearches = .suggested
            
            // We are no longer interested in cell navigating, since we are now showing the suggested searches.
            searchResultsController.tableView.delegate = searchResultsController
            
            if isLandscape {
                self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: .none)
            }
        }
    }
    
    // User tapped the Done button in the keyboard.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        keyboardDismissed()

        guard let text = searchController.searchBar.text, let searchField = searchField else { return }
        
        if !text.isEmpty && searchField.tokens.isEmpty, let text = searchField.text {
            fetchAndParse(suggestedSearch: .tag(text))
        }
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
        if let searchField = searchField {
            searchField.insertToken(token, at: searchField.tokens.count > 0 ? searchField.tokens.count : 0)
            searchField.text = ""
            
            if let searchTokenValue = token.representedObject as? SearchCategories {
                switch searchTokenValue {
                    case .tags:
                        searchResultsController.showSuggestedSearches = .additionalSuggest
                        
                        if isLandscape {
                            if self.splitViewController?.detailViewController == nil {
                                replaceDetailVC(searchCategory: searchTokenValue)
                            }
                            
                            self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchTokenValue)
                        }
                    case .tag(_):
                        if searchField.tokens.count == 2 {
                            searchResultsController.showSuggestedSearches = .none
                        }
                    case .topics:
                        searchResultsController.showSuggestedSearches = .additionalSuggest
                        
                        if isLandscape {
                            if self.splitViewController?.detailViewController == nil {
                                print("searchTokenValue before", searchTokenValue)
                                replaceDetailVC(searchCategory: searchTokenValue)
                            }
                            self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchTokenValue)
                        }
                    case .topic(_):
                        searchResultsController.showSuggestedSearches = .none
                    default:
                        searchResultsController.showSuggestedSearches = .none
                        
                        if isLandscape {
                            if self.splitViewController?.detailViewController == nil {
                                replaceDetailVC(searchCategory: searchTokenValue)
                            }
                            
                            self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchTokenValue)
                        }
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
        let button = self.splitViewController?.displayModeButtonItem
        itemDetailVC.navigationItem.leftBarButtonItem = button
        itemDetailVC.navigationItem.leftItemsSupplementBackButton = true
        let nav = UINavigationController(rootViewController: itemDetailVC)
        self.showDetailViewController(nav, sender: self)
    }
}

// MARK: - Left view delegate

extension ViewController: LeftViewDelegate {
    func didApplyFilter() {
        // run the search depending on what is present in the search field
        if let searchField = searchField, searchField.tokens.count > 0 {
            updateSearchResults(for: searchController!)
        }
        
        searchResultsController.updateFilterButton()
    }
}

// MARK: - Search bar cancel button clicked

extension ViewController {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isLandscape {
            replaceDetailVC(searchCategory: nil)
        }
    }
    
    func replaceDetailVC(searchCategory: SearchCategories?) {
        if let navControllers = self.splitViewController?.viewControllers[1] {
            let existingVC = (navControllers as! UINavigationController).viewControllers[0]
            existingVC.willMove(toParent: nil)
            existingVC.removeFromParent()
            
            // add
            let detailViewController = DetailViewController()
            let nav = UINavigationController(rootViewController: detailViewController)
            self.showDetailViewController(nav, sender: self)
            self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchCategory)
            NotificationCenter.default.post(name: .detailDismissed, object:self)
        }
    }
}

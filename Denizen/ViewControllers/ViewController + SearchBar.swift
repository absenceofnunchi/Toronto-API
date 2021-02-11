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
            self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: .none)
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
            searchField.text = ""

            if let searchTokenValue = token.representedObject as? SearchCategories {
                switch searchTokenValue {
                    case .tags:
                        searchResultsController.showSuggestedSearches = .additionalSuggest
                        self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchTokenValue)
                    case .tag(_):
                        if searchField.tokens.count == 2 {
                            searchResultsController.showSuggestedSearches = .none
                        }
                    case .topics:
                        searchResultsController.showSuggestedSearches = .additionalSuggest
                        self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchTokenValue)
                    case .topic(_):
                        searchResultsController.showSuggestedSearches = .none
                    default:
                        searchResultsController.showSuggestedSearches = .none
                        self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: searchTokenValue)
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
        
        let nav = UINavigationController(rootViewController: itemDetailVC)
        
        if ViewController.windowInterfaceOrientation!.isLandscape {
            let button = self.splitViewController?.displayModeButtonItem
            itemDetailVC.navigationItem.leftBarButtonItem = button
            itemDetailVC.navigationItem.leftItemsSupplementBackButton = true
            itemDetailVC.navigationItem.hidesBackButton = true

            if let nav2 = self.splitViewController?.viewControllers[1] as? UINavigationController {
                nav2.pushViewController(itemDetailVC, animated: true)
            }
            
//            self.showDetailViewController(nav, sender: self)
        } else {
            if self.traitCollection.horizontalSizeClass == .compact {
                navigationController?.pushViewController(itemDetailVC, animated: true)
            } else {
                let button = self.splitViewController?.displayModeButtonItem
                itemDetailVC.navigationItem.leftBarButtonItem = button
                itemDetailVC.navigationItem.leftItemsSupplementBackButton = true
                self.showDetailViewController(nav, sender: self)
            }
        }
    }
}

// MARK: - Left view delegate

extension ViewController: LeftViewDelegate {
    func didApplyFilter(with filters: [Filter]) {
        // add the newly acquired filters to the filters array property
        if self.filters.count > 0 {
            self.filters.removeAll()
        }
        
        filters.forEach { self.filters.append($0) }
        
        // run the search depending on what is present in the search field
        if let searchField = navigationItem.searchController?.searchBar.searchTextField, searchField.tokens.count > 0 {
            updateSearchResults(for: searchController!)
        }
        
        searchResultsController.updateFilterButton()
    }
}

extension ViewController {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if let nav = self.splitViewController?.viewControllers[1] as? UINavigationController {
            nav.popToRootViewController(animated: true)
        }
        
        self.splitViewController?.detailViewController?.createAnnotation(searchCateogry: .none)
    }
}

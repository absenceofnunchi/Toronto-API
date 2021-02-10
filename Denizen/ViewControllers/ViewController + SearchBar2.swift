////
////  ViewController + SearchBar.swift
////  Denizen
////
////  Created by J C on 2021-01-25.
////
///*
// Abstract:
// defines the search controller, which involves,
//    1. set the apepearance of the search bar and the search text field
//    2. set the search results controller
//    3. define what happens when the user taps on the items from search results controller
// */
//
//import UIKit
//
//// MARK: - Search results controller
//
//extension ViewController {
//    
//    // configure search controller
//    func configureSearchController() {
//        searchResultsController = SearchResultsController()
//        searchResultsController.suggestedSearchDelegate = self // So we can be notified when a suggested search token is selected.
//        
//        searchController = UISearchController(searchResultsController: searchResultsController)
//        searchController.searchResultsUpdater = self
//        searchController.isActive = true
//        searchController.delegate = self
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.obscuresBackgroundDuringPresentation = false
//        
//        definesPresentationContext = true
//        navigationItem.searchController = searchController
//    }
//}
//
//// MARK:- Search bar
//
//extension ViewController: UISearchBarDelegate {
//    
//    // search bar and search field appearance
//    func configureSearchBar() {
//        // search bar attributes
//        let searchBar = searchController!.searchBar
//        searchBar.delegate = self
//        searchBar.autocapitalizationType = .none
//        searchBar.sizeToFit()
//        searchBar.tintColor = .black
//        searchBar.searchBarStyle = .minimal
//        
////        // set the search bar height
//        let size = CGSize(width: 1, height: 50)
////        let renderer = UIGraphicsImageRenderer(size: size)
////        let image = renderer.image { (_) in
////            UIColor.white.setFill()
////            let rect = UIBezierPath(rect: CGRect(origin: .zero, size: size))
////            rect.fill()
////        }
////        searchBar.setSearchFieldBackgroundImage(image, for: .normal)
//        
//        // search text field attributes
//        let searchTextField = searchBar.searchTextField
//        searchTextField.borderStyle = .roundedRect
//        searchTextField.layer.cornerRadius = 8
//        searchTextField.layer.borderWidth = 1
//        searchTextField.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
//        searchTextField.frame = CGRect(origin: .zero, size: size)
//        
//        let filterButton = UIButton.systemButton(with: UIImage(systemName: "line.horizontal.3.decrease.circle")!, target: self, action: #selector(leftViewButtonHandler))
//        filterButton.frame = CGRect(x: 0, y: 0, width: 50, height: searchTextField.frame.height)
//        filterButton.backgroundColor = .clear
//        searchTextField.leftView = filterButton
//        searchTextField.leftViewMode = .always
//        
//        // cancel button location adjustment
//        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
//        cancelButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: .default)
//    }
//    
//    @objc func leftViewButtonHandler() {
////        let text = searchController.searchBar.searchTextField.text
//        let filterViewController = FilterViewController(style: .insetGrouped)
//        filterViewController.delegate = self
//        let navController = UINavigationController(rootViewController: filterViewController)
//        self.present(navController, animated: true, completion: nil)
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text!.isEmpty {
//            setToSuggestedSearches()
//        } else if searchBar.searchTextField.tokens.isEmpty {
//            searchResultDetailVC?.showSuggestedSearches = .none
//        }
//    }
//    
//    func setToSuggestedSearches() {
//
//        // Show suggested searches only if we don't have a search token in the search field.
//        if searchController.searchBar.searchTextField.tokens.isEmpty {
//            removeChildVC()
////            searchResultsController.showSuggestedSearches = .suggested
//            
//            // We are no longer interested in cell navigating, since we are now showing the suggested searches.
//            searchResultsController.tableView.delegate = searchResultsController
//        }
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        // User tapped the Done button in the keyboard.
//        searchController.dismiss(animated: true, completion: nil)
//        searchBar.text = ""
//    }
//}
//
//// MARK: - UISearchControllerDelegate
//// Use these delegate functions for additional control over the search controller.
//
//extension ViewController: UISearchControllerDelegate {
//    
//    // We are being asked to present the search controller, so from the start - show suggested searches.
//    func presentSearchController(_ searchController: UISearchController) {
//        searchController.showsSearchResultsController = true
//        setToSuggestedSearches()
//    }
//}
//
//// MARK:- SuggestedSearch protocol conformance
//
//extension ViewController: SuggestedSearch {
//    // SearchResultsController selected a suggested search, so we need to apply the search token.
//    func didSelectSuggestedSearch(token: UISearchToken) {
//        guard let windowInterfaceOrientation = ViewController.windowInterfaceOrientation else { return }
//
//        if let searchField = self.navigationItem.searchController?.searchBar.searchTextField {
//            // if the same token already exists, don't add another one
//            let tokens = searchField.tokens
//            for case let existingToken in tokens where existingToken.representedObject as! SearchCategories == token.representedObject as! SearchCategories {
//                return
//            }
//
//            // If selecting one of the first tier tokens, make sure to delete the existing tokens
//            // This is because the search results controller screen stays in a landscape mode
//            let firstTierTokens: [SearchCategories] = [.tags, .civicIssues, .packages, .qualityScores, .recentlyChanged, .topics]
//            var count = searchField.tokens.count
//            if tokens.count > 0 && firstTierTokens.contains(token.representedObject as! SearchCategories) {
//                while count > 0 {
//                    searchField.removeToken(at: count - 1)
//                    count -= 1
//                }
//            }
//            
//            searchField.insertToken(token, at: count > 0 ? count: 0)
//            searchField.text = ""
//            
//            if windowInterfaceOrientation.isLandscape {
//                // activate landscape changes
//                // depending on the interface orientation and depending on the search token value
//                // the search and display methods are going to be different
//                // If landscape, open in a split view.
//                // If portrait, open in a search result controller
//                
//
//                if let searchTokenValue = token.representedObject as? SearchCategories {
//                    switch searchTokenValue {
//                        case .tags:
//                            searchResultsController.showSuggestedSearches = .additionalSuggest
//                        case .tag(_):
//                            if searchField.tokens.count == 2 {
//                                print("run")
//                                addchildVC(searchState: .none)
////                                searchResultDetailVC?.showSuggestedSearches = .none
////                                self.showDetailViewController(searchResultDetailVC, sender: self)
//                            }
//                        case .topics:
//                            searchResultDetailVC?.showSuggestedSearches = .additionalSuggest
//                            self.showDetailViewController(searchResultDetailVC, sender: self)
//                        case .topic(_):
//                            searchResultDetailVC?.showSuggestedSearches = .none
////                            self.showDetailViewController(searchResultDetailVC, sender: self)
//                        default:
//                            searchResultDetailVC?.showSuggestedSearches = .none
////                            self.showDetailViewController(searchResultDetailVC, sender: self)
//                    }
//                }
//            } else {
//                // portrait
//                if let searchTokenValue = token.representedObject as? SearchCategories {
//                    switch searchTokenValue {
//                        case .tags:
//                            addchildVC(searchState: .additionalSuggest)
//                        case .tag(_):
//                            if searchField.tokens.count == 2 {
//                                addchildVC(searchState: .none)
//                            }
//                        case .topics:
//                            addchildVC(searchState: .additionalSuggest)
//                        case .topic(_):
//                            addchildVC(searchState: .none)
//                        default:
//                            addchildVC(searchState: .none)
//                    }
//                }
//            }
//            // Update the search query with the newly inserted token
//            updateSearchResults(for: searchController!)
//        }
//    }
//    
//    func addchildVC(searchState: SearchState) {
////        if searchResultDetailVC == nil {
////            searchResultDetailVC = SearchResultDetailTableViewController()
////        }
//
//        searchResultDetailVC = SearchResultDetailTableViewController()
//
//        let childView = searchResultDetailVC.view!
//        let parentView = searchResultsController.view!
//        childView.translatesAutoresizingMaskIntoConstraints = false
//
//        searchResultsController.addChild(searchResultDetailVC)
//        searchResultsController.view.addSubview(childView)
//        searchResultDetailVC.didMove(toParent: searchResultsController)
//        searchResultDetailVC.suggestedSearchDelegate = self
//        searchResultDetailVC?.showSuggestedSearches = searchState
//        
//        NSLayoutConstraint.activate([
//            childView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
//            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
//            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
//            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
//            childView.widthAnchor.constraint(equalTo: parentView.widthAnchor)
//        ])
//    }
//    
//    func removeChildVC() {
//        if searchResultDetailVC != nil {
//            searchResultDetailVC.willMove(toParent: nil)
//            searchResultDetailVC.view.removeFromSuperview()
//            searchResultDetailVC.removeFromParent()
//            searchResultDetailVC = nil
//        }
//    }
//    
////    func configureOrientation() {
////        guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
////        if windowInterfaceOrientation.isLandscape {
////            removeChildVC()
////        } else {
////            addchildVC()
////        }
////    }
//    
//    // SearchResultscontroller selected an item so navigate to that item
//    func didSelectItem(fetchedData: FetchedData) {
//        // Set up the detail view controller to show
//        let itemDetailVC = ItemDetailViewController()
//        itemDetailVC.fetchedData = fetchedData
//        self.showDetailViewController(itemDetailVC, sender: self)
////        searchResultDetailVC.navigationController?.pushViewController(itemDetailVC, animated: true)
//    }
//}
//
//// MARK: - Left view delegate
//
//extension ViewController: LeftViewDelegate {
//    func didApplyFilter(with filters: [Filter]) {
//        // add the newly acquired filters to the filters array property
//        if self.filters.count > 0 {
//            self.filters.removeAll()
//        }
//        
//        filters.forEach { self.filters.append($0) }
//        
//        // run the search depending on what is present in the search field
//        if let searchField = navigationItem.searchController?.searchBar.searchTextField, searchField.tokens.count > 0 {
//            updateSearchResults(for: searchController!)
//        }
//     
//        guard let windowInterfaceOrientation = ViewController.windowInterfaceOrientation else { return }
//        if windowInterfaceOrientation.isPortrait {
//            searchResultDetailVC.updateFilterButton()
//        }
//    }
//}

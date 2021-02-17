//
//  AppProtocols.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import Foundation
import MapKit

// MARK: - Suggested search
// This protocol helps inform ViewController from SearchResultsController that a suggested search or product was selected.
protocol SuggestedSearch: AnyObject {
    /// This protocol helps inform MainTableViewController that a suggested search or product was selected.
    func didSelectSuggestedSearch(token: UISearchToken)
    
    /// A product was selected; inform our delgeate that a product was selected to view.
    func didSelectItem(fetchedData: FetchedData)
}

// MARK: - Filter delegate
// Passes the value of the selected filter from FilterSettingsTableViewController to FilterViewController
protocol FilterDelegate: AnyObject {
    func didSelectFilter(selectedFilter: Filter, setting: String)
}

// MARK: - left view delegate
// Passes the value to be applied as a filter from FilterViewController to ViewController
protocol LeftViewDelegate: AnyObject {
    func didApplyFilter()
}

// MARK: - Data source delegate
protocol DataSourceDelegate: AnyObject {
    func didSelectCellAtIndexPath(at indexPath: IndexPath, with fetchedData: FetchedData)
    func didFetchData()
}

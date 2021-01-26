//
//  AppProtocols.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import Foundation
import MapKit

// This protocol helps inform ViewController from SearchResultsController that a suggested search or product was selected.
protocol SuggestedSearch: AnyObject {
    /// This protocol helps inform MainTableViewController that a suggested search or product was selected.
    func didSelectSuggestedSearch(token: UISearchToken)
    
    /// A product was selected; inform our delgeate that a product was selected to view.
    func didSelectProduct(product: Item)
}

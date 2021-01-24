//
//  AppProtocols.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import Foundation
import MapKit

// view controller
protocol AddressFetchDelegate: AnyObject {
    /// Passes the address selection.
    /// - Parameter MKPlaceMark: The selected address from search results controller
    /// - Throws Void
    /// - Returns: Void
    /// - Takes the address selected from the search results controller and passes it to `ViewController` to be used.
    func didFetchAddress(_ address: MKPlacemark)
}

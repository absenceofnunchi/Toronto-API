//
//  AsyncFetcherOperation.swift
//  Denizen
//
//  Created by J C on 2021-01-24.
//

import Foundation

class AsyncFetcherOperation: Operation {
    // MARK:- Properties
    
    let identifier: UUID
    var fetchedData: [FetchedData]?
    
    // MARK:- Initialization
    
    init(identifier: UUID) {
        self.identifier = identifier
    }
}

// MARK:- Operation overrides

extension AsyncFetcherOperation {
    override func main() {
        guard !isCancelled else { return } 
    }
}

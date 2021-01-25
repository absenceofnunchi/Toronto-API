//
//  AyncFetcher.swift
//  Denizen
//
//  Created by J C on 2021-01-24.
//

/*
 Abstract:
 A class for fetching data asynchronously.
*/

import Foundation

class AsyncFetcher {
    // MARK: - Properties
    
    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    private var completionHandlers = [UUID: [(FetchedData?) -> Void]]()
    private var cache = NSCache<NSUUID, FetchedData>()
    
    // MARK: - Initialization
    
    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
        serialAccessQueue.qualityOfService = .background
    }
}

// MARK: - Object fetching

extension AsyncFetcher {
    /**
     Asynchronously fetches data for a specified `UUID`.
     
     - Parameters:
     - identifier: The `UUID` to fetch data for.
     - completion: An optional called when the data has been fetched.
     */
    func fetchAsync(_ identifier: UUID, completion: ((FetchedData?) -> Void)? = nil) {
        if let completion = completion {
            let handlers = self.completionHandlers[identifier, default: []]
            self.completionHandlers[identifier] = handlers + [completion]
        }
        
        self.fetchData(for: identifier)
    }
    
    /**
     Returns the previously fetched data for a specified `UUID`.
     
     - Parameter identifier: The `UUID` of the object to return.
     - Returns: The 'DisplayData' that has previously been fetched or nil.
     */
    func fetchedData(for identifier: UUID) -> FetchedData? {
        return cache.object(forKey: identifier as NSUUID)
    }
    
    /**
     Cancels any enqueued asychronous fetches for a specified `UUID`. Completion
     handlers are not called if a fetch is canceled.
     
     - Parameter identifier: The `UUID` to cancel fetches for.
     */
    func cancelFetch(_ identifier: UUID) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }
            
            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }
    
    /**
     Begins fetching data for the provided `identifier` invoking the associated
     completion handler when complete.
     
     - Parameter identifier: The `UUID` to fetch data for.
     */
    
    private func fetchData(for identifier: UUID) {
        // If a request has already been made for the object, do nothing more.
        guard operation(for: identifier) == nil else { return }
        
        if let data = fetchedData(for: identifier) {
            invokeCompletionHandlers(for: identifier, with: data)
        } else {
            let operation = AsyncFetcherOperation(identifier: identifier)
            
            // Set the operation's completion block to cache the fetched object and call the associated completion blocks.
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
//                self.cache.setObject(fetchedData, forKey: identifier as NSUUID)
            }
            
            fetchQueue.addOperation(operation)
        }
    }
    
    /**
     Returns any enqueued `ObjectFetcherOperation` for a specified `UUID`.
     
     - Parameter identifier: The `UUID` of the operation to return.
     - Returns: The enqueued `ObjectFetcherOperation` or nil.
     */
    private func operation(for identifier: UUID) -> AsyncFetcherOperation? {
        for case let fetchOperation as AsyncFetcherOperation in fetchQueue.operations
        where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
            return fetchOperation
        }
        
        return nil
    }
    
    private func invokeCompletionHandlers(for identifier: UUID, with fetchedData: FetchedData) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil
        
        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}

// first run
// 1. Pass the identifier and the escaping closure
// 2. Set the completionHandler dictionary's key to the identifier and the value to the closure. This is to be invoked after the data is fetched.
//    We add this to the serial queue because we want this to be done while the fetch is done.
// 3. Fetch the data, cache it, and invoke the completion handler. Add this to the fetch queue.


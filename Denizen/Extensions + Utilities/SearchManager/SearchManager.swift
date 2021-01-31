//
//  SearchManager.swift
//  Denizen
//
//  Created by J C on 2021-01-27.
//

import Foundation

protocol SearchManager {
    var actionType: ActionType { get }
    var queryKey: QueryKey { get }
    var urlWithQuery: String { get }
    func fetchAPI(url: String, parameters: [QueryKey: String]?,  completion: @escaping ([String: Any]?, Error?) -> Void)
}


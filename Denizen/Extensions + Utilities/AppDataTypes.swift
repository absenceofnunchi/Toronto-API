//
//  AppDataTypes.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import Foundation

// MARK:- Cell identifier

struct Cell {
    static var menuCell = "menu-cell-reuse-identifier"
    static var supplementaryCell = "title-supplementary-reuse-identifier"
}

// MARK: - URL
/// WebServiceManager and prefetch

struct URLScheme {
    static var baseURL = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/"
    
    struct Subdomain {
        // JSON-formatted lists
        static var tags = "tag_list"
        static var packages = "package_list"
        static var recentlyChanged = "recently_changed_packages_activity_list"
        static var qualityScores = "datastore_search"
        
        // full JSON representation
        static var tagShow = "tag_show"
        
        struct id {
            static var qualityScoresId = "?id=22f223e7-73f7-4842-935c-80a0ba5c3e5b"
        }
    }
}

enum QueryKey: String {
    case id = "id"
    case limit = "limit"
}

//enum QueryValue: String {
//    case
//}

enum ActionType: String {
    case tagShow = "tag_show"
    case packageShow = "package_show"
    case datastoreSearch = "datastore_search"
}


// MARK: - API fetched data types

class Item {
    enum ColorKind: Int {
        case red = 0
        case green = 1
        case blue = 2
        case yellow = 3
    }
    
    var id: String!
    var searchCategories: SearchCategories!
    
    init(id: String) {
        self.id = id
    }
}

class CatalogueQualityScores: Item {
    var package: String!
    
    //    let grade_norm: Medal
    //    let _id: Int
    //    let accessibility: Int
    //    let completeness: Float
    //    let freshness: Int
    //    let grade: String
    //    let metadata: Float
    //    let recorded_at: Date
    //    let score: Float
    //    let score_norm: Float
    //    let usability: Float
    //    let version: String
    
    init(package: String, id: String) {
        super.init(id: id)
        self.package = package
    }
}

class RecentlyChanged: Item {
    var title: String!
    
    init(title: String, id: String) {
        super.init(id: id)
        self.title = title
    }
}

struct FetchedData {
    var id: String? = nil
    let title: String
    var searchCategories: SearchCategories
    var parameters: [QueryKey: String]? = nil
}


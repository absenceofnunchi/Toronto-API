//
//  AppDataTypes.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import UIKit

// MARK:- Cell identifier

struct Cell {
    static var searchResultCell = "search-result-cell"
    static var menuCell = "menu-cell-reuse-identifier"
    static var supplementaryCell = "title-supplementary-reuse-identifier"
    static var itemDetailCell = "item-detail-cell-identifier"
    static var filterCell = "filter-cell-identifier"
    static var mapDetailCell = "map-detail-cell-identifier"
    static var searchResultTableCell = "search-result-table-cell"
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
            static var qualityScoresId = "22f223e7-73f7-4842-935c-80a0ba5c3e5b"
        }
    }
}

struct Query: Hashable {
    struct ActionType {
        static var tagShow = "tag_show"
        static var packageShow = "package_show"
        static var datastoreSearch = "datastore_search"
        static var packageSearch = "package_search"
    }
    
    struct Key {
        static var id = "id"
        static var limit = "limit"
        static var fq = "fq"
        static var q = "q"
        static var facetField = "facet.field"
        static var rows = "rows"
        static var sort = "sort"
    }
    
    struct Filter {
        static var tags = "tags"
        static var none = ""
    }
}

// MARK: - API fetched data types

class Item {
    enum ColorKind: Int {
        case red = 0
        case green = 1
        case blue = 2
        case yellow = 3
        case orange = 4
    }
    
    var id: String!
    var searchCategories: SearchCategories!
    
    init(id: String) {
        self.id = id
    }
}

//class CatalogueQualityScores: Item {
//    var package: String!
//    
//    init(package: String, id: String) {
//        super.init(id: id)
//        self.package = package
//    }
//}
//
//class RecentlyChanged: Item {
//    var title: String!
//    var date: String!
//    
//    init(title: String, id: String, date: String) {
//        super.init(id: id)
//        self.title = title
//        self.date = date
//    }
//}

struct FetchedData: Hashable {
    var id: String? = nil
    let title: String
    var date: String? = nil
    var searchCategories: SearchCategories? = nil
    var parameters: [String: String]? = nil
}

enum SearchState {
    case none, suggested, additionalSuggest
}

// MARK: - ItemInfo
/// ExpandDetailViewController

struct ItemInfo {
    let header: String?
    let body: String?
    let dict: [String: AnyObject]?
    let itemInfoType: ItemInfoType
}

enum ItemInfoType {
    case textViewOnly, labelAndTextView, dict, noType
}

// MARK: - PaddedLabel

class PaddedLabel: UILabel {
    var topInset: CGFloat = 15.0
    var bottomInset: CGFloat = 15.0
    var leftInset: CGFloat = 15.0
    var rightInset: CGFloat = 15.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += topInset + bottomInset
            contentSize.width += leftInset + rightInset
            return contentSize
        }
    }
}


// MARK: - SearchCategories
/// SearchResultsController, WebServiceManager
enum SearchCategories: Equatable, Hashable {
    case tags, packages, recentlyChanged, qualityScores, tagPackageShow, topics, civicIssues
    case tag(String), topic(String)
    
    var value: String {
        switch self {
            case .tags:
                return "Tags"
            case .packages:
                return "Packages"
            case .recentlyChanged:
                return "Recently Changed"
            case .qualityScores:
                return "Quality Scores"
            case .tagPackageShow:
                return "package_show"
            case .topics:
                return "Topics"
            case .tag(let title):
                return title
            case .topic(let title):
                return title
            case .civicIssues:
                return "Civic Issues"
        }
    }
}

// MARK: - Filter

class Filter {
    var title: FilterType!
    var setting: String!
    var url: String? {
        if setting == "All" {
            // no need for a parameter if it's default
            return nil
        } else {
            if title == .orderBy {
                return setting
            } else {
                return title.facet + ":" + "\"" + setting + "\""
            }
        }
    }
    
    init(title: FilterType, setting: String) {
        self.title = title
        self.setting = setting
    }
}

// MARK: - Filter Type

enum FilterType: String, CaseIterable {
    case publisher = "Publisher"
    case refreshRate = "Refresh Rate"
    case format = "Format"
    case type = "Type"
    case orderBy = "Order By"
    
    var facet: String {
        switch self {
            case .publisher:
                return "owner_division"
            case .refreshRate:
                return "refresh_rate"
            case .format:
                return "formats"
            case .type:
                return "dataset_category"
            case .orderBy:
                return "sort"
        }
    }
}

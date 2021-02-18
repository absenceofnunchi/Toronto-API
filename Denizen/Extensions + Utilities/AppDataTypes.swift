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
    static var favouriteCell = "favourite-reuse-identifier"
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
        static var packageAutocomplete = "package_autocomplete"
        static var activityList = "package_activity_list"
        
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
        static var userList = "user_list"
        static var userShow = "user_show"
        static var vocabularyList = "vocabulary_list"
        static var helpShow = "help_show"
    }
    
    struct Key {
        static var id = "id"
        static var limit = "limit"
        static var fq = "fq"
        static var q = "q"
        static var facetField = "facet.field"
        static var rows = "rows"
        static var sort = "sort"
        static var name = "name"
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

struct Keys {
    static var id = "id"
    static var title = "title"
    static var date = "date"
    static var searchCategories = "seachCategories"
    static var parameters = "parameters"
    static var favourites = "favourties"
}

//class FetchedData: NSObject, NSCoding {
//    let uuid = UUID()
//    var id: String? = nil
//    let title: String
//    var date: String? = nil
//    var searchCategories: SearchCategories? = nil
//    var parameters: [String: String]? = nil
//
//    init(id: String? = nil, title: String, date: String? = nil, searchCategories: SearchCategories? = nil, parameters: [String: String]? = nil) {
//        self.id = id
//        self.title = title
//        self.date = date
//        self.searchCategories = searchCategories
//        self.parameters = parameters
//    }
//
////    required convenience init(coder aDecoder: NSCoder) {
////        let id = aDecoder.decodeObject(forKey: Keys.id.rawValue) as! String
////        let title = aDecoder.decodeObject(forKey: Keys.title.rawValue) as! String
////        let date = aDecoder.decodeObject(forKey: Keys.date.rawValue) as! String
////        let searchCategories = aDecoder.decodeObject(forKey: Keys.searchCategories.rawValue) as! SearchCategories
////        let parameters = aDecoder.decodeObject(forKey: Keys.parameters.rawValue) as! [String: String]
////        self.init(id: id, title: title, date: date, searchCategories: searchCategories, parameters: parameters)
////    }
//
//    required convenience init?(coder aDecoder: NSCoder) {
//        guard let id = aDecoder.decodeObject(forKey: Keys.id) as? String,
//              let title = aDecoder.decodeObject(forKey: Keys.title) as? String,
//              let date = aDecoder.decodeObject(forKey: Keys.date) as? String,
////              let searchCategories = aDecoder.decodeObject(forKey: Keys.searchCategories) as? SearchCategories,
//              let parameters = aDecoder.decodeObject(forKey: Keys.parameters) as? [String: String] else { return nil }
//
//        self.init(id: id, title: title, date: date, parameters: parameters)
//    }
//
////    public func encode(with coder: NSCoder) {
////        coder.encode(id, forKey: Keys.id)
////        coder.encode(title, forKey: Keys.title)
////        coder.encode(date, forKey: Keys.date)
////        coder.encode(searchCategories, forKey: Keys.searchCategories)
////        coder.encode(parameters, forKey: Keys.parameters)
////    }
//
//    public func encode(with coder: NSCoder) {
//        if let id = id {
//            coder.encode(id, forKey: Keys.id)
//        }
//        coder.encode(title, forKey: Keys.title)
//        if let date = date {
//            coder.encode(date, forKey: Keys.date)
//        }
////        if let searchCategories = searchCategories {
////            coder.encode(searchCategories, forKey: Keys.searchCategories)
////        }
//        if let parameters = parameters {
//            coder.encode(parameters, forKey: Keys.parameters)
//        }
//    }
//
////    static func == (lhs: FetchedData, rhs: FetchedData) -> Bool {
////        return lhs.uuid == rhs.uuid
////    }
//
////    func hash(into hasher: inout Hasher) {
////        hasher.combine(uuid)
////    }
//}

class FetchedData: Codable, Equatable {
    let uuid = UUID()
    var id: String? = nil
    let title: String
    var date: String? = nil
    var searchCategories: SearchCategories? = nil
    var parameters: [String: String]? = nil
    
    private enum CodingKeys: String, CodingKey {
        case id, title, date, searchCategories, parameters
    }
    
    init(id: String? = nil, title: String, date: String? = nil, searchCategories: SearchCategories? = nil, parameters: [String: String]? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.searchCategories = searchCategories
        self.parameters = parameters
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try? container.decode(String.self, forKey: .date)
        searchCategories = try? container.decode(SearchCategories.self, forKey: .searchCategories)
        parameters = try? container.decode([String: String].self, forKey: .parameters)
    }

    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let id = id {
            try container.encode(id, forKey: .id)
        }
        
        try container.encode(title, forKey: .title)
        
        if let date = date {
            try container.encode(date, forKey: .date)
        }
        
        if let searchCategories = searchCategories {
            try container.encode(searchCategories, forKey: .searchCategories)
        }
        
        if let parameters = parameters {
            try container.encode(parameters, forKey: .parameters)
        }
    }
    
    static func == (lhs: FetchedData, rhs: FetchedData) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

enum SearchState {
    case none, suggested, additionalSuggest, notices
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
//enum SearchCategories: Equatable, Hashable, Codable {
//    init(from decoder: Decoder) throws {
//        <#code#>
//    }
//
//    func encode(to encoder: Encoder) throws {
//        <#code#>
//    }
//
//    case tags, packages, recentlyChanged, qualityScores, tagPackageShow, topics, civicIssues
//    case tag(String), topic(String)
//
//    var value: String {
//        switch self {
//            case .tags:
//                return "Tags"
//            case .packages:
//                return "Packages"
//            case .recentlyChanged:
//                return "Recently Changed"
//            case .qualityScores:
//                return "Quality Scores"
//            case .tagPackageShow:
//                return "package_show"
//            case .topics:
//                return "Topics"
//            case .tag(let title):
//                return title
//            case .topic(let title):
//                return title
//            case .civicIssues:
//                return "Civic Issues"
//        }
//    }
//}

enum SearchCategories: Equatable, Hashable, Codable {
    case tags
    case packages
    case recentlyChanged
    case qualityScores
    case tagPackageShow
    case topics
    case civicIssues
    case tag(String)
    case topic(String)
    case notices
    case admins
    case vocabularyList
    case helpShow
    case licenses
    case packageAutocomplete
    case activityList
    
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
            case .notices:
                return "Notices"
            case .admins:
                return "Admins"
            case .vocabularyList:
                return "Vocabulary List"
            case .helpShow:
                return "Help"
            case .licenses:
                return "Licenses"
            case .packageAutocomplete:
                return "Package Autocomplete"
            case .activityList:
                return "Activity List"
        }
    }
}

extension SearchCategories {
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
     
    enum CodingError: Error {
        case unknownValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
            case 0:
                self = .tags
            case 1:
                self = .packages
            case 2:
                self = .recentlyChanged
            case 3:
                self = .qualityScores
            case 4:
                self = .tagPackageShow
            case 5:
                self = .topics
            case 6:
                let title = try container.decode(String.self, forKey: .associatedValue)
                self = .tag(title)
            case 7:
                let title = try container.decode(String.self, forKey: .associatedValue)
                self = .topic(title)
            case 8:
                self = .civicIssues
            case 9:
                self = .notices
            case 10:
                self = .admins
            case 11:
                self = .vocabularyList
            case 12:
                self = .helpShow
            case 13:
                self = .licenses
            case 14:
                self = .packageAutocomplete
            case 15:
                self = .activityList
            default:
                throw CodingError.unknownValue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
            case .tags:
                try container.encode(0, forKey: .rawValue)
            case .packages:
                try container.encode(1, forKey: .rawValue)
            case .recentlyChanged:
                try container.encode(2, forKey: .rawValue)
            case .qualityScores:
                try container.encode(3, forKey: .rawValue)
            case .tagPackageShow:
                try container.encode(4, forKey: .rawValue)
            case .topics:
                try container.encode(5, forKey: .rawValue)
            case .tag(let title):
                try container.encode(6, forKey: .rawValue)
                try container.encode(title, forKey: .associatedValue)
            case .topic(let title):
                try container.encode(7, forKey: .rawValue)
                try container.encode(title, forKey: .associatedValue)
            case .civicIssues:
                try container.encode(8, forKey: .rawValue)
            case .notices:
                try container.encode(9, forKey: .rawValue)
            case .admins:
                try container.encode(10, forKey: .rawValue)
            case .vocabularyList:
                try container.encode(11, forKey: .rawValue)
            case .helpShow:
                try container.encode(12, forKey: .rawValue)
            case .licenses:
                try container.encode(13, forKey: .rawValue)
            case .packageAutocomplete:
                try container.encode(14, forKey: .rawValue)
            case .activityList:
                try container.encode(15, forKey: .rawValue)
                
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

// MARK: -  Styled alert controller

private var windows: [String:UIWindow] = [:]

extension UIWindowScene {
    static var focused: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }
}

class StyledAlertController: UIAlertController {
    var wid: String?
    
    func present(animated: Bool, completion: (() -> Void)?) {
        
        //let window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = UIWindowScene.focused.map(UIWindow.init(windowScene:)) else {
            return
        }
        window.rootViewController = UIViewController()
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        window.rootViewController!.present(self, animated: animated, completion: completion)
        
        wid = UUID().uuidString
        windows[wid!] = window
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let wid = wid {
            windows[wid] = nil
        }
        
    }
    
}

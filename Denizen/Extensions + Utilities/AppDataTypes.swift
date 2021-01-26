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

struct MyURL {
    static var baseURL = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/"
}

struct Subdomain {
    static var tags = "tag_list"
    static var packages = "package_list"
    static var recentlyChanged = "recently_changed_packages_activity_list"
    static var qualityScores = "datastore_search"
}

// MARK: - SearchCategories
/// SearchResultsController, WebServiceManager

enum SearchCategories: String, CaseIterable {
    case tags = "Tags"
    case packages = "Packages"
    case recentlyChanged = "Recently Changed"
    case qualityScores = "Quality Scores"
}


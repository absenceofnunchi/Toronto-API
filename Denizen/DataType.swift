//
//  DataType.swift
//  Denizen
//
//  Created by J C on 2021-01-24.
//

import Foundation

class FetchedData: NSObject {
    let identifier = UUID()
}

class CatalogueQualityScores: FetchedData {
    let package: String

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
 
    init(package: String) {
        self.package = package
    }
}

class RecentlyChanged: FetchedData {
    let title: String
    init(title: String) {
        self.title = title
    }
}

struct Item {
    enum ColorKind: Int {
        case red = 0
        case green = 1
        case blue = 2
        case yellow = 3
    }
}

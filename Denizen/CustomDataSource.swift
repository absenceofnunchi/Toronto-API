//
//  SearchResultsController.swift
//  Denizen
//
//  Created by J C on 2021-01-20.
//

/*
 Abstract:
 A class that implements both `UICollectionViewDataSource` and `UICollectionViewDataSourcePrefetching`.
 */


import UIKit

class CustomDataSource: NSObject, UICollectionViewDataSource {
    private var supplementaryView: UICollectionReusableView!
    private var offsetBy: Int = 0
    private var Y_OF_HEADER_VIEW: CGFloat! = 0
    private var data = [Item]()
    
    // api request
    let OFFSET_CONSTANT = 30

    override init() {
        super.init()
        
        configureInitialData()
    }
}

// MARK:- Data source

extension CustomDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.menuCell, for: indexPath) as? MenuCell else {
            fatalError("Expected `\(MenuCell.self)` type for reuseIdentifier \(MenuCell.reuseIdentifier). Check the configuration.")
        }
        
        let datum = data[indexPath.row] as! RecentlyChanged
//        let identifier = datum.identifier
//        cell.representedIdentifier = identifier
        
//        if let fetchedData = asyncFetcher
        
        cell.label.text = datum.title
        cell.contentView.backgroundColor = .white
        cell.contentView.shadowBorder()
        cell.label.textAlignment = .center
        cell.label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cell.label.textColor = .lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.supplementaryCell, for: indexPath) as? TitleSupplementaryView else {
            fatalError("Expected `\(TitleSupplementaryView.self)` type for reuseIdentifier \(TitleSupplementaryView.reuseIdentifier). Check the configuration.")
        }
        self.Y_OF_HEADER_VIEW = supplementaryView.bounds.origin.y
        
        supplementaryView.label.text = "Recently Changed"
        supplementaryView.label.textColor = .gray
        supplementaryView.layer.cornerRadius = 10
        
        self.supplementaryView = supplementaryView
        
        return supplementaryView
    }
}

// MARK: - Initial data

extension CustomDataSource {
    func configureInitialData() {        
        let recentlyChanged = SearchCategories.recentlyChanged
        recentlyChanged.fetchAPI(url: recentlyChanged.url, parameters: [.limit:"30"]) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                return
            }

            if let result = responseObject["result"] as? [[String: Any]] {
                result.forEach { (package) in
                    if let data = package["data"] as? [String: Any],
                       let package = data["package"] as? [String: Any],
                       let title = package["title"] as? String,
                       let id = package["id"] as? String {
                        self.data.append(RecentlyChanged(title: title, id: id))
                    }
                }
            }
        }
//        WebServiceManager.shared.sendRequest(subdomain: Subdomain.recentlyChanged, parameters: parameters) { (responseObject, error) in
//            guard let responseObject = responseObject, error == nil else {
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//
//            if let result = responseObject["result"] as? [[String: Any]] {
//                result.forEach { (package) in
//                    if let data = package["data"] as? [String: Any], let package = data["package"] as? [String: Any], let title = package["title"] as? String {
//                        self.data.append(RecentlyChanged(title: title))
//                    }
//                }
//            }
//        }
    }
}

// MARK: - Request next data set

extension CustomDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // prefetch network data 5 rows prior to the end of the existing data
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 10 {
            updateNextSet(collectionView)
        }
    }

    func updateNextSet(_ collectionView: UICollectionView){
//     if indexPath.row == data.count - 5 {
//        let fetchQueue = OperationQueue()
//        fetchQueue.qualityOfService = .background
//        fetchQueue.addOperation {
//            self.offsetBy += 1
//            let parameters: [String: String] = ["limit": "30", "offset": String(self.OFFSET_CONSTANT * self.offsetBy)]
//            self.webServiceManager.sendRequest(self.urlString, parameters: parameters) { (responseObject, error) in
//                guard let responseObject = responseObject, error == nil else {
//                    print(error?.localizedDescription ?? "Unknown error")
//                    return
//                }
//
//                if let result = responseObject["result"] as? [[String: Any]] {
//                    result.forEach { (package) in
//                        if let data = package["data"] as? [String: Any], let package = data["package"] as? [String: Any], let title = package["title"] as? String {
//                            self.data.append(RecentlyChanged(title: title))
//                        }
//                    }
//                            DispatchQueue.main.async {
//                                collectionView.reloadData()
//                            }
//                }
//            }
//        }
//        }
    }
}

// MARK: - Scroll view delegate

extension CustomDataSource: UICollectionViewDelegate {
    // changes the atttributes of the supplementary view once it floats
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cell = supplementaryView as? TitleSupplementaryView {
            if scrollView.contentOffset.y > Y_OF_HEADER_VIEW {
                cell.backgroundColor = UIColor(red: 253/255, green: 184/255, blue: 39/255, alpha: 1)
                cell.label.textColor = .white
            } else {
                cell.backgroundColor = .clear
                cell.label.textColor = .gray
            }
        }
    }
}

// MARK:- UICollectionViewDataSourcePrefetching

extension CustomDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        for index in indexPaths {
//            print("index row", index.row)
//            print("data count", data.count - 5)
//            // prefetch network data 5 rows prior to the end of the existing data
//            if index.row == data.count - 5 {
//                let fetchQueue = OperationQueue()
//                fetchQueue.qualityOfService = .background
//                fetchQueue.addOperation {
//                    self.offsetBy += 1
//                    let parameters: [String: String] = ["limit": "5", "offset": String(self.OFFSET_CONSTANT * self.offsetBy)]
//                    self.webServiceManager.sendRequest(self.urlString, parameters: parameters) { (responseObject, error) in
//                        guard let responseObject = responseObject, error == nil else {
//                            print(error?.localizedDescription ?? "Unknown error")
//                            return
//                        }
//                        
//                        if let result = responseObject["result"] as? [[String: Any]] {
//                            result.forEach { (package) in
//                                if let data = package["data"] as? [String: Any], let package = data["package"] as? [String: Any], let title = package["title"] as? String {
//                                    self.data.append(RecentlyChanged(title: title))
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}

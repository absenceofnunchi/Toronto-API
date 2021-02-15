//
//  ViewController + DataSource.swift
//  Denizen
//
//  Created by J C on 2021-02-12.
//

import UIKit

extension ViewController: UICollectionViewDataSource {

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
        
        let datum = data[indexPath.row]
        cell.titleLabel.text = datum.title
        if let dateString = datum.date {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            if let date = dateFormatter.date(from:dateString) {
                dateFormatter.dateStyle = .short
                let finalString = dateFormatter.string(from: date)
                cell.dateLabel.text = "Updated on \(finalString)"
            }
        }
        
        cell.contentView.backgroundColor = .white
        cell.contentView.shadowBorder()
        
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
    
    
    // when in portrait, the detail vc is stuck when it turns to landscape
    // unable to either dismiss, or show new detail vc
    // can't see the default detail vc
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name:.detailChosen, object:self)

        let itemDetailVC = ItemDetailViewController()
        let fetchedData = data[indexPath.item]
        itemDetailVC.fetchedData = fetchedData

        let nav = UINavigationController(rootViewController: itemDetailVC)
        self.showDetailViewController(nav, sender: self)
    }
}

// MARK: - Initial data

extension ViewController {
    func configureInitialData() {
        
        let parameters = [Query.Key.limit: "30"]
        WebServiceManager.shared.sendRequest(urlString: urlString, parameters: parameters) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                    let alertController = UIAlertController(title: "Network Error", message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            if let result = responseObject["result"] as? [[String: Any]] {
                result.forEach { (package) in
                    if let data = package["data"] as? [String: Any],
                       let package = data["package"] as? [String: Any],
                       let title = package["title"] as? String,
                       let id = package["id"] as? String,
                       let date = package["metadata_modified"] as? String {
                        let parameters: [String: String] = [Query.Key.id: id]
                        self.data.append(FetchedData(id: id, title: title, date: date, searchCategories: .recentlyChanged, parameters: parameters))
                    }
                }
            }
        }
    }
}

// MARK: - Request next data set

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // prefetch network data 5 rows prior to the end of the existing data
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 10 {
            updateNextSet(collectionView)
        }
    }
    
    func updateNextSet(_ collectionView: UICollectionView){
        let fetchQueue = OperationQueue()
        fetchQueue.qualityOfService = .background
        fetchQueue.addOperation {
            self.offsetBy += 1
            let parameters: [String: String] = ["limit": "30", "offset": String(self.OFFSET_CONSTANT * self.offsetBy)]
            WebServiceManager.shared.sendRequest(urlString: self.urlString, parameters: parameters) { (responseObject, error) in
                guard let responseObject = responseObject, error == nil else {
                    print(error?.localizedDescription ?? "Unknown error")
                    let alertController = UIAlertController(title: "Network Error", message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                if let result = responseObject["result"] as? [[String: Any]] {
                    result.forEach { (package) in
                        if let data = package["data"] as? [String: Any],
                           let package = data["package"] as? [String: Any],
                           let title = package["title"] as? String,
                           let id = package["id"] as? String,
                           let date = package["metadata_modified"] as? String {
                            let parameters: [String: String] = [Query.Key.id: id]
                            self.data.append(FetchedData(id: id, title: title, date: date, searchCategories: .recentlyChanged, parameters: parameters))
                        }
                    }
                    DispatchQueue.main.async {
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - Scroll view delegate

extension ViewController: UICollectionViewDelegate {
    // changes the atttributes of the supplementary view once it floats
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cell = supplementaryView as? TitleSupplementaryView {
            if scrollView.contentOffset.y > Y_OF_HEADER_VIEW {
                cell.backgroundColor = .clear
                cell.label.isHidden = true
            } else {
                cell.backgroundColor = .clear
                cell.label.textColor = .gray
                cell.label.isHidden = false
            }
        }
    }
}

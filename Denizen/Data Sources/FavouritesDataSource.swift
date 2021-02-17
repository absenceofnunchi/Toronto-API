//
//  FavouritesDataSource.swift
//  Denizen
//
//  Created by J C on 2021-02-16.
//

import Foundation

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

class FavouritesDataSource: NSObject, UICollectionViewDataSource {
    private var data = [FetchedData]()
    private let defaults = UserDefaults.standard
    weak var dataSourceDelegate:DataSourceDelegate?

    init(dataSourceDelegate: DataSourceDelegate) {
        super.init()
        self.dataSourceDelegate = dataSourceDelegate
        configureInitialData()
    }
}

// MARK:- Data source

extension FavouritesDataSource: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.favouriteCell, for: indexPath) as? MenuCell else {
            fatalError("Expected `\(MenuCell.self)` type for reuseIdentifier \(MenuCell.reuseIdentifier). Check the configuration.")
        }
        
        let datum = data[indexPath.row]
        cell.titleLabel.text = datum.title
        cell.dateLabel.text = datum.id
        cell.contentView.backgroundColor = .white
        cell.contentView.shadowBorder()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name:.detailChosen, object:self)
        let fetchedData = data[indexPath.item]
        dataSourceDelegate?.didSelectCellAtIndexPath(at: indexPath, with: fetchedData)
    }
}

// MARK: - Initial data

extension FavouritesDataSource {
    func configureInitialData() {
        do {
            if let savedFavourites = defaults.object(forKey: Keys.favourites) as? Data {
                let decoded = try JSONDecoder().decode([FetchedData].self, from: savedFavourites)
                data = decoded
                dataSourceDelegate?.didFetchData()
            }
        } catch (let error){
            print(error)
        }
    }
}


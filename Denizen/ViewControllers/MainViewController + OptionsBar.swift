//
//  ViewController + MenuBar.swift
//  Denizen
//
//  Created by J C on 2021-02-02.
//
/*
 Abstract:
 The options bar navigation item for the filter button and the layout button
 */

import UIKit

extension MainViewController {
    
    func configureOptionsBar() {
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Filter", comment: ""), image: UIImage(systemName: "doc.on.doc"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Layout", comment: ""), image: UIImage(systemName: "pencil"), handler: menuHandler),
        ])
        
        let image = UIImage(systemName: "line.horizontal.3.decrease")?.withRenderingMode(.alwaysOriginal)
        if #available(iOS 14.0, *) {
            optionsBarItem = UIBarButtonItem(title: nil, image: image, primaryAction: nil, menu: barButtonMenu)
            navigationItem.rightBarButtonItem = optionsBarItem
        } else {
            optionsBarItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(menuHandler(action:)))
            navigationItem.rightBarButtonItem = optionsBarItem
        }
    }
    
    @objc func menuHandler(action: UIAction) {
        switch action.title {
            case "Filter":
                let filterViewController = FilterViewController(style: .insetGrouped)
                let navController = UINavigationController(rootViewController: filterViewController)
                self.present(navController, animated: true, completion: nil)
            case "Layout":
                keyboardDismissed()
                searchController.showsSearchResultsController = false
                if layoutType == 3 {
                    layoutType = 1
                } else {
                    layoutType += 1
                }
                DispatchQueue.main.async {
                    self.collectionView.setCollectionViewLayout(self.createLayout(with: self.layoutType), animated: true, completion: nil)
                    if self.favouriteView != nil {
                        self.favouriteView.setCollectionViewLayout(self.createLayout(with: self.layoutType), animated: true, completion: nil)
                    }
                }
            default:
                break
        }
    }
}

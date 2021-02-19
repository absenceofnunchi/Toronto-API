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
            UIAction(title: NSLocalizedString("Layout", comment: ""), image: UIImage(systemName: "square.grid.2x2"), handler: menuHandler),
            UIAction(title: NSLocalizedString("License", comment: ""), image: UIImage(systemName: "c.circle"), handler: menuHandler)
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
//            case "Filter":
//                let filterViewController = FilterViewController()
//                let navController = UINavigationController(rootViewController: filterViewController)
//                self.present(navController, animated: true, completion: nil)
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
            case "License":
                let alertController = UIAlertController(title: "License", message: "This app contains information licensed under the Open Government Licence – Toronto.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Go To Website", style: .default, handler: { (_) in
                    if let url = URL(string: "https://www.toronto.ca/city-government/data-research-maps/open-data/open-data-licence/"), !url.absoluteString.isEmpty {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                self.present(alertController, animated: true, completion: nil)
            default:
                break
        }
    }
}

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

extension ViewController {
    
    func configureOptionsBar() {
        let barButtonMenu = UIMenu(title: "", children: [
            UIAction(title: NSLocalizedString("Filter", comment: ""), image: UIImage(systemName: "doc.on.doc"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Layout", comment: ""), image: UIImage(systemName: "pencil"), handler: menuHandler),
            UIAction(title: NSLocalizedString(Menu.orientation.toggled!, comment: ""), image: UIImage(systemName: "plus.square.on.square"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Move", comment: ""), image: UIImage(systemName: "folder"), handler: menuHandler)
        ])
        
        let image = UIImage(systemName: "line.horizontal.3.decrease")?.withRenderingMode(.alwaysOriginal)
        optionsBarItem = UIBarButtonItem(title: nil, image: image, primaryAction: nil, menu: barButtonMenu)
        navigationItem.rightBarButtonItem = optionsBarItem
    }
    
    @objc func menuHandler(action: UIAction) {
        switch action.title {
            case "Filter":
                let filterViewController = FilterViewController(style: .insetGrouped)
                let navController = UINavigationController(rootViewController: filterViewController)
                self.present(navController, animated: true, completion: nil)
            case "Orientation":
                UIView.setAnimationsEnabled(false)
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIView.setAnimationsEnabled(true)
            case "Layout":
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

enum Menu: String {
    case orientation, Portrait, Landscape
    var toggled: String? {
        switch self {
            case .orientation:
                if UIDevice.current.orientation.isLandscape {
                    return Menu.Portrait.rawValue
                } else {
                    return Menu.Landscape.rawValue
                }
            default:
                return nil
        }
    }
}

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
            UIAction(title: NSLocalizedString("Duplicate", comment: ""), image: UIImage(systemName: "plus.square.on.square"), handler: menuHandler),
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
            default:
                break
        }
    }
}

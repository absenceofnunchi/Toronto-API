//
//  ContainerViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-08.
//

import UIKit

class ContainerViewController: UIViewController {
    var svc = UISplitViewController()
    var didInitialSetup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSplitVC()
    }
    
    override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        guard let windowInterfaceOrientation = ContainerViewController.windowInterfaceOrientation else { return nil }
        
        if windowInterfaceOrientation.isLandscape {
            // activate landscape changes
            return UITraitCollection(traitsFrom: [UITraitCollection(horizontalSizeClass: .regular)])
        } else {
            // activate portrait changes
            return super.traitCollection
        }
    }
}

extension ContainerViewController: UISplitViewControllerDelegate {
    func configureSplitVC() {
        svc.delegate = self
        svc.view.backgroundColor = .white
        
        // master
        let vc = ViewController()
        let nav1 = UINavigationController(rootViewController: vc)
        
        // detail
        let detailViewController = DetailViewController()
        let nav2 = UINavigationController(rootViewController: detailViewController)
        nav2.view.tag = 2000
        
        svc.viewControllers = [nav1, nav2]
        
//        let button = svc.displayModeButtonItem
//        detailViewController.navigationItem.leftBarButtonItem = button
//        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        self.addChild(svc)
        self.view.addSubview(svc.view)
        svc.view.frame = self.view.bounds
        svc.didMove(toParent: self)
    }
    
    func splitViewController(_ svc: UISplitViewController, collapseSecondary vc2: UIViewController, onto vc1: UIViewController) -> Bool {
        return true
    }
}

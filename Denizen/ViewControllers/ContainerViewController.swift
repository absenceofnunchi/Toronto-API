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
    var nav1: UINavigationController!
    var nav2: UINavigationController!
    var interVC: UIViewController!
    var detailChosen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSplitVC()
        configureObserver()
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

extension ContainerViewController {
    func configureObserver() {
        NotificationCenter.default.addObserver(forName: .detailChosen, object: nil, queue: nil) { (_) in
            print("notification true")
            self.detailChosen = true
        }
        
        NotificationCenter.default.addObserver(forName: .detailDismissed, object: nil, queue: nil) { (_) in
            print("notification false")
            self.detailChosen = false
        }
    }
}

extension ContainerViewController: UISplitViewControllerDelegate {
    func configureSplitVC() {
        svc.delegate = self
        svc.view.backgroundColor = .white
//        svc.preferredDisplayMode = .automatic
        svc.view.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
        
        // master
        let vc = ViewController()
        nav1 = UINavigationController(rootViewController: vc)
        nav1.view.tag = 1000
        
        // detail
        let detailViewController = DetailViewController()
        nav2 = UINavigationController(rootViewController: detailViewController)
        nav2.view.tag = 2000
        
        svc.viewControllers = [nav1, nav2]
        
        let button = svc.displayModeButtonItem
        detailViewController.navigationItem.leftBarButtonItem = button
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        self.addChild(svc)
        self.view.addSubview(svc.view)
        svc.view.frame = self.view.bounds
        svc.didMove(toParent: self)
    }
    
    func splitViewController(_ svc: UISplitViewController, collapseSecondary vc2: UIViewController, onto vc1: UIViewController) -> Bool {
        if self.detailChosen {
            print("detail chosen true")
            return false
        }
        print("detail chosen false")
        return true
    }

    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        print("topColumnForCollapsingToProposedTopColumn", proposedTopColumn)

        return proposedTopColumn
    }
    
    func splitViewController(_ svc: UISplitViewController, willShow column: UISplitViewController.Column) {
        print(column, "will show")
    }
    
    func splitViewController(_ svc: UISplitViewController, willHide column: UISplitViewController.Column) {
        print(column, "will hide")
    }
    
    func splitViewControllerDidCollapse(_ svc: UISplitViewController) {
        
    }
    
    func splitViewControllerDidExpand(_ svc: UISplitViewController) {

    }
    
    func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
        return proposedDisplayMode
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
    }
}


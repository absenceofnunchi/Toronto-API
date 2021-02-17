//
//  CustomTabBarController.swift
//  Denizen
//
//  Created by J C on 2021-02-15.
//

import UIKit

class CustomTabBarController: UIViewController {
    var catalogueVC: ViewController!
    var favouriteVC: FavouriteCollectionViewController!
    var nav1: UINavigationController!
    var nav2: UINavigationController!
    var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        configureTabBar()
        configureInitialVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Did select

extension CustomTabBarController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
            case 1:
                print("tab 1")
                
                if nav1 == nil {
                    catalogueVC = ViewController()
                    nav1 = UINavigationController(rootViewController: catalogueVC)
                }
                view.insertSubview(nav1.view, belowSubview: tabBar)
                
//                catalogueVC = ViewController()
//                if favouriteVC != nil {
//                    favouriteVC.willMove(toParent: nil)
//                    favouriteVC.beginAppearanceTransition(false, animated: true)
//                    catalogueVC.beginAppearanceTransition(true, animated: true)
//                    UIView.transition(from: favouriteVC.view, to: catalogueVC.view, duration: 0.4, options: .transitionCrossDissolve) { (_) in
//                        self.catalogueVC.endAppearanceTransition()
//                        self.favouriteVC.endAppearanceTransition()
//                        self.catalogueVC.didMove(toParent: self)
//                        self.favouriteVC.removeFromParent()
//                        self.favouriteVC = nil
//                    }
//                } else {
//                    view.addSubview(nav1.view)
//                    catalogueVC.view.frame = view.bounds
//                    catalogueVC.didMove(toParent: self)
//                }
            case 2:
                print("tab 2")
                if nav2 == nil {
                    favouriteVC = FavouriteCollectionViewController()
                    nav2 = UINavigationController(rootViewController: favouriteVC)
                }
                view.insertSubview(nav2.view, belowSubview: tabBar)
                
//                favouriteVC = FavouriteCollectionViewController()
//                addChild(favouriteVC)
//                if catalogueVC != nil {
//                    catalogueVC.willMove(toParent: nil)
//                    catalogueVC.beginAppearanceTransition(false, animated: true)
//                    favouriteVC.beginAppearanceTransition(true, animated: true)
//                    UIView.transition(from: catalogueVC.view, to: favouriteVC.view, duration: 0.4, options: .transitionCrossDissolve) { (_) in
//                        self.favouriteVC.endAppearanceTransition()
//                        self.catalogueVC.endAppearanceTransition()
//                        self.favouriteVC.didMove(toParent: self)
//                        self.catalogueVC.removeFromParent()
//                        self.catalogueVC = nil
//                    }
//                } else {
//                    view.addSubview(favouriteVC.view)
//                    favouriteVC.view.frame = view.bounds
//                    favouriteVC.didMove(toParent: self)
//                }
            default:
                break
        }
    }
}

// MARK: - Configure initial VC

extension CustomTabBarController {
    func configureInitialVC() {
        catalogueVC = ViewController()
        nav1 = UINavigationController(rootViewController: catalogueVC)
        view.insertSubview(nav1.view, belowSubview: tabBar)
        
//        addChild(catalogueVC)
//        view.addSubview(catalogueVC.view)
//        catalogueVC.view.frame = view.bounds
//        catalogueVC.didMove(toParent: self)
    }
}

// MARK: - Tab bar

extension CustomTabBarController {
    func configureTabBar() {
        tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.delegate = self
        tabBar.layer.zPosition = 1
        
        let catalogue = UITabBarItem(title: "Catalogue", image: nil, tag: 1)
        let favourite = UITabBarItem(title: "Favourite", image: nil, tag: 2)
        tabBar.items = [catalogue, favourite]
        view.addSubview(tabBar)
        
        NSLayoutConstraint.activate([
            tabBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 80),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//
//  ViewController+TabBar.swift
//  Denizen
//
//  Created by J C on 2021-02-15.
//

import UIKit

extension ViewController {
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
            tabBar.heightAnchor.constraint(equalToConstant: 60),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabNumber = item.tag
        switch item.tag {
            case 1:
                if favouriteView != nil {
                    NSLayoutConstraint.deactivate(constraints)
                }
                
                if collectionView == nil {
                    configureCollectionViewHierarchy()
                }
                
                constraints = [
                    collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    collectionView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                ]
                
                if favouriteView != nil {
                    UIView.transition(from: favouriteView, to: collectionView, duration: 0.4, options: .transitionCrossDissolve) { (_) in
                        NSLayoutConstraint.activate(self.constraints)
                    }
                } else {
                    view.addSubview(collectionView)
                    NSLayoutConstraint.activate(constraints)
                }
                
                favouriteView = nil
            case 2:
                if collectionView != nil {
                    NSLayoutConstraint.deactivate(constraints)
                }
                
                if favouriteView == nil {
                    configureFavouriteViewHierarchy()
                    configureFavouritesCellRegister()
                }
                
                constraints = [
                    favouriteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                    favouriteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    favouriteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    favouriteView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                ]
                
                if collectionView != nil {
                    UIView.transition(from: collectionView, to: favouriteView, duration: 0.2, options: .transitionCrossDissolve) { (_) in
                        NSLayoutConstraint.activate(self.constraints)
                    }
                } else {
                    view.addSubview(favouriteView)
                    NSLayoutConstraint.activate(self.constraints)
                }                
            default:
                break
        }
    }
}

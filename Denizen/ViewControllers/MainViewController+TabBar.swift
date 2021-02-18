//
//  ViewController+TabBar.swift
//  Denizen
//
//  Created by J C on 2021-02-15.
//

import UIKit

extension MainViewController: CustomTabBarDelegate {
    func tabBarDidSelect(with tag: Int) {
        tabNumber = tag
        switch tag {
            case 0:
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
                    collectionView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -1),
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
            case 1:
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
                    favouriteView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -1),
                ]
                
                if collectionView != nil {
                    UIView.transition(from: collectionView, to: favouriteView, duration: 0.2, options: .transitionCrossDissolve) { (_) in
                        NSLayoutConstraint.activate(self.constraints)
                    }
                } else {
                    view.insertSubview(favouriteView, belowSubview: tabBar)
                    NSLayoutConstraint.activate(self.constraints)
                }                
            default:
                break
        }
    }
}

extension MainViewController {
    func configureTabBar() {
        tabBar = CustomTabBar()
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)
        
        NSLayoutConstraint.activate([
            tabBar.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            tabBar.heightAnchor.constraint(equalToConstant: 60),
            tabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
}

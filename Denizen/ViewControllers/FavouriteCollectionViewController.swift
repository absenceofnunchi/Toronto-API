//
//  FavouriteCollectionViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-14.
//

import UIKit

class FavouriteCollectionViewController: UIViewController {
    var layoutType: Int = 1
    var collectionView: UICollectionView! = nil
    var data = [FetchedData]()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInitialData()
        configureHierarchy()
        configureCellRegister()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let itemDetailVC = ItemDetailViewController()
        self.showDetailViewController(itemDetailVC, sender: self)
    }
}

// MARK:- Navigation controller

extension FavouriteCollectionViewController {
    func configureNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Denizen"
        navigationItem.hidesSearchBarWhenScrolling = false
        extendedLayoutIncludesOpaqueBars = true
        
        applyImageBackgroundToTheNavigationBar()
    }
    
    @objc func rightBarButtonHandler() {
        collectionView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
        
        if layoutType == 3 {
            layoutType = 1
        } else {
            layoutType += 1
        }
        
        self.collectionView.setCollectionViewLayout(self.createLayout(with: layoutType), animated: true, completion: nil)
    }
    
    func applyImageBackgroundToTheNavigationBar() {
        var updatedFrame = self.navigationController!.navigationBar.bounds
        updatedFrame.size.height += view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 100
        
        let gradientLayer = GradientLayer(updatedFrame: updatedFrame)
        gradientLayer.setNeedsDisplay()
        
        let renderer = UIGraphicsImageRenderer(size: gradientLayer.bounds.size)
        let image = renderer.image { (ctx) in
            let cgContext = ctx.cgContext
            gradientLayer.render(in: cgContext)
        }
        self.navigationController!.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        
        let appearance = navigationController!.navigationBar.standardAppearance.copy()
        appearance.backgroundImage = image
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

// MARK:- Create Layout

extension FavouriteCollectionViewController {
    /// Creates a grid layout for the collection view
    /// - Parameter Int
    /// - Throws None
    /// - Returns UICollectionViewLayout
    /// - Creates layouts dynamically, 1, 2, or 3 columns. Event from right bar button
    func createLayout(with layoutType: Int = 1) -> UICollectionViewLayout {
        // group
        var group: NSCollectionLayoutGroup!
        switch layoutType {
            case 1:
                group = singleColumnLayout()
            case 2:
                group = doubleColumnLayout()
            case 3:
                group = tripleColumnLayout()
            default:
                break
        }
        
        // section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 20)
        
        // layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func singleColumnLayout() -> NSCollectionLayoutGroup {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        return group
    }
    
    func doubleColumnLayout() -> NSCollectionLayoutGroup {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return group
    }
    
    func tripleColumnLayout() -> NSCollectionLayoutGroup {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.4))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        return group
    }
}

// MARK:- Hierarchy

extension FavouriteCollectionViewController {
    /// Creates a collection view
    /// - Parameter None
    /// - Throws None
    /// - Returns Void
    /// - Creates a collection view and adds it to the main view as a subview
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout(with: layoutType))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - Cell register

extension FavouriteCollectionViewController {
    func configureCellRegister() {
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Cell.menuCell)
    }
}

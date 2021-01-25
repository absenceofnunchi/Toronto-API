//
//  SearchResultsController.swift
//  Denizen
//
//  Created by J C on 2021-01-20.
//

/*
 Abstract:
 The main page that shows the menu of all categories.
 The search bar allows the users to search for a particular menu.
 */

import UIKit
import MapKit

class ViewController: UIViewController {
    static let sectionHeaderElementKind = "section-header-element-kind"
    private var searchController: UISearchController?
    private var collectionView: UICollectionView! = nil
    private var layoutType: Int = 1
    private let dataSource = CustomDataSource()
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
        
        configureNavigationController()
        configureSearchController()
        configureSearchBar()
        configureHierarchy()
        configureCellRegister()
    }
}

// MARK:- Navigation controller

extension ViewController {
    func configureNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Denizen"
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(rightBarButtonHandler))
        navigationItem.rightBarButtonItem = rightBarButton
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
}


// MARK:- Search bar

extension ViewController: UISearchBarDelegate {
    
    // configure search controller
    func configureSearchController() {
        let searchResultsController = SearchResultsController()
        let mapView = MKMapView()
        searchResultsController.mapView = mapView
        searchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController?.searchResultsUpdater = searchResultsController
        searchController?.isActive = true
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    func configureSearchBar() {
        // search bar attributes
        let searchBar = searchController!.searchBar
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.sizeToFit()
        searchBar.tintColor = .black
        searchBar.searchBarStyle = .minimal
        
        // set the search bar height
        let size = CGSize(width: 1, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { (_) in
            UIColor.white.setFill()
            let rect = UIBezierPath(rect: CGRect(origin: .zero, size: size))
            rect.fill()
        }
        searchBar.setSearchFieldBackgroundImage(image, for: .normal)
        
        // search text field attributes
        let searchTextField = searchBar.searchTextField
        searchTextField.borderStyle = .none
        searchTextField.layer.cornerRadius = 8
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
        searchTextField.frame = CGRect(origin: .zero, size: size)
        
        // cancel button location adjustment
        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        cancelButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: .default)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //        if webServiceManager == nil {
        //            webServiceManager = WebServiceManager(packageId: packageId, urlString: urlString2)
        //        } else {
        //            webServiceManager.packageId = packageId
        //            webServiceManager.urlString = urlString2
        //        }
        //
        //        webServiceManager.useOfAPIRequest()
        
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("clicked")
    }
}

// MARK:- AddressFetchDelegate

extension ViewController: AddressFetchDelegate {
    func didFetchAddress(_ address: MKPlacemark) {
        print(address)
    }
}

// MARK:- Create Layout
extension ViewController {
    /// Creates a grid layout for the collection view
    /// - Parameter Int
    /// - Throws None
    /// - Returns UICollectionViewLayout
    /// - Creates layouts dynamically, 1, 2, or 3 columns. Event from right bar button
    private func createLayout(with layoutType: Int = 1) -> UICollectionViewLayout {
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
        
        // section header
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: ViewController.sectionHeaderElementKind, alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        sectionHeader.zIndex = 2
        section.boundarySupplementaryItems = [sectionHeader]

        // layout
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func singleColumnLayout() -> NSCollectionLayoutGroup {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
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
extension ViewController {
    /// Creates a collection view
    /// - Parameter None
    /// - Throws None
    /// - Returns Void
    /// - Creates a collection view and adds it to the main view as a subview
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout(with: layoutType))
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.prefetchDataSource = dataSource
        collectionView.isPrefetchingEnabled = true
        view.addSubview(collectionView)
    }
}


// MARK: - Cell register

extension ViewController {
    func configureCellRegister() {
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: Cell.menuCell)
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: ViewController.sectionHeaderElementKind, withReuseIdentifier: Cell.supplementaryCell)
    }
}
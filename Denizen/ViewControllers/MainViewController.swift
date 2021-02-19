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

class MainViewController: UIViewController {
    // MARK:- Properties

    static let sectionHeaderElementKind = "section-header-element-kind"
    
    // The suffix portion of the user activity type for this view controller.
    static let activitySuffix = "mainRestored "

    var searchController: UISearchController!
    var searchResultsController: SearchResultsController!
    var suggestArray = [FetchedData]()    
    var optionsBarItem: UIBarButtonItem!
    let defaults = UserDefaults.standard
    var searchField: UISearchTextField? {
        return navigationItem.searchController?.searchBar.searchTextField
    }
    var layoutType: Int = 1
    var collectionView: UICollectionView! = nil
    var favouriteView: UICollectionView! = nil
    var collectionViewDataSource: CollectionViewDataSource!
    lazy var favouritesDataSource = FavouritesDataSource(dataSourceDelegate: self)
    var tabBar: CustomTabBar!
    var tabNumber = 0
    var constraints: [NSLayoutConstraint]!
    private var accessoryDoneButton: UIBarButtonItem!
    private var accessoryToolBar: UIToolbar!
    
    // data source
    var supplementaryView: UICollectionReusableView!
    var offsetBy: Int = 0
    var Y_OF_HEADER_VIEW: CGFloat! = 0
    var data = [FetchedData]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    let urlString = URLScheme.baseURL + URLScheme.Subdomain.recentlyChanged
    // api request
    let OFFSET_CONSTANT = 30
    override var prefersStatusBarHidden: Bool { true }
    var isInitialLoad = false
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isInitialLoad = true
        collectionViewDataSource = CollectionViewDataSource()
        collectionViewDataSource.dataSourceDelegate = self
        
        configureSearchController()
        configureOptionsBar()
        configureTabBar()
        configureCollectionViewHierarchy()
        configureNavigationController()
        configureSearchBar()
        configureCollectionCellRegister()
        configureKeyboardDismiss()
        
        constraints = [
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -1)
        ]
        NSLayoutConstraint.activate(constraints)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let orientation: UIInterfaceOrientationMask = .all
            delegate.supportedOrientation = orientation
        }
    }
}

// MARK:- Navigation controller

extension MainViewController {
    func configureNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesSearchBarWhenScrolling = false
//        extendedLayoutIncludesOpaqueBars = true

        navigationItem.title = "Toronto API"
        applyImageBackgroundToTheNavigationBar()
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
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}

// MARK:- Create Layout

extension MainViewController {
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        
        // section header
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: MainViewController.sectionHeaderElementKind, alignment: .top)
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

extension MainViewController: DataSourceDelegate {
    /// Creates a collection view
    /// - Parameter None
    /// - Throws None
    /// - Returns Void
    /// - Creates a collection view and adds it to the main view as a subview
    func configureCollectionViewHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout(with: layoutType))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.delegate = collectionViewDataSource
        collectionView.dataSource = collectionViewDataSource
        collectionView.isPrefetchingEnabled = true
        
        if isInitialLoad {
            view.insertSubview(collectionView, belowSubview: tabBar)
        }
    }
    
    func configureFavouriteViewHierarchy() {
        favouriteView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout(with: layoutType))
        favouriteView.translatesAutoresizingMaskIntoConstraints = false
        favouriteView.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
        favouriteView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        favouriteView.delegate = favouritesDataSource
        favouriteView.dataSource = favouritesDataSource
    }
    
    func didSelectCellAtIndexPath(at indexPath: IndexPath, with fetchedData: FetchedData){
        if fetchedData.searchCategories == .notices {
            let webViewController = WebViewController()
            webViewController.fetchedData = fetchedData
            webViewController.dataSourceDelegate = favouritesDataSource

            let button = self.splitViewController?.displayModeButtonItem
            button?.tintColor = .lightGray
            webViewController.navigationItem.leftBarButtonItem = button
            webViewController.navigationItem.leftItemsSupplementBackButton = true
            
            let nav = UINavigationController(rootViewController: webViewController)
            self.showDetailViewController(nav, sender: self)
        } else {
            let itemDetailVC = ItemDetailViewController()
            itemDetailVC.fetchedData = fetchedData
            itemDetailVC.dataSourceDelegate = favouritesDataSource

            let button = self.splitViewController?.displayModeButtonItem
            button?.tintColor = .lightGray
            itemDetailVC.navigationItem.leftBarButtonItem = button
            itemDetailVC.navigationItem.leftItemsSupplementBackButton = true
            
            let nav = UINavigationController(rootViewController: itemDetailVC)
            self.showDetailViewController(nav, sender: self)
        }
    }
    
    func didFetchData() {
        DispatchQueue.main.async {
            if self.tabNumber == 0 {
                self.collectionView.reloadData()
            } else {
                self.favouriteView.reloadData()
            }
        }
    }
}

// MARK: - Cell register

extension MainViewController {
    func configureCollectionCellRegister() {
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: Cell.menuCell)
        collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: MainViewController.sectionHeaderElementKind, withReuseIdentifier: Cell.supplementaryCell)
    }
    
    func configureFavouritesCellRegister() {
        favouriteView.register(MenuCell.self, forCellWithReuseIdentifier: Cell.favouriteCell)
        favouriteView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: MainViewController.sectionHeaderElementKind, withReuseIdentifier: Cell.supplementaryCell)
    }
}

// MARK: - Keyboard dissmiss

extension MainViewController {
    func configureKeyboardDismiss() {
        accessoryDoneButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down")!, style: .plain, target: self, action: #selector(keyboardDismissed))
        accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        accessoryToolBar.items = [accessoryDoneButton]
        searchField?.inputAccessoryView = accessoryToolBar
    }
    
    @objc func keyboardDismissed() {
        searchField?.resignFirstResponder()
    }
}

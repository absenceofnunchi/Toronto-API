
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
//
//import UIKit
//import MapKit
//
//class ViewController: UIViewController {
//    // section for collection view
//    enum Section {
//        case main
//    }
//    static let sectionHeaderElementKind = "section-header-element-kind"
//    var searchController: UISearchController?
//    var webServiceManager: WebServiceManager!
//    var dataSource: UICollectionViewDiffableDataSource<String, CatalogueQualityScores>! = nil
//    var collectionView: UICollectionView! = nil
//    var snapshot: NSDiffableDataSourceSnapshot<String, CatalogueQualityScores>! = nil
//    var fieldsArr = [Field]()
//    var resultArr = [Package]()
//    var layoutType: Int = 1
//    var Y_OF_HEADER_VIEW: CGFloat! = 0
//    var supplementaryView: UICollectionReusableView!
//    var offsetBy: Int = 0
//
//    override var prefersStatusBarHidden: Bool { true }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(red: (247/255), green: (247/255), blue: (247/255), alpha: 1)
//
//        configureNavigationController()
//        configureSearchController()
//        configureSearchBar()
//        configureHierarchy()
//        configureDataSource()
//        configureAPIRequest()
//    }
//}
//
//// MARK: - Scroll view delegate
//
//extension ViewController: UIScrollViewDelegate, UICollectionViewDelegate {
//    // changes the atttributes of the supplementary view once it floats
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let cell = supplementaryView as? TitleSupplementaryView {
//            if scrollView.contentOffset.y > Y_OF_HEADER_VIEW {
//                cell.backgroundColor = UIColor(red: 253/255, green: 184/255, blue: 39/255, alpha: 1)
//                cell.label.textColor = .white
//            } else {
//                cell.backgroundColor = .clear
//                cell.label.textColor = .gray
//            }
//        }
//    }
//}
//
//// MARK:- Navigation controller
//
//extension ViewController {
//    func configureNavigationController() {
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.title = "Denizen"
//
//        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(rightBarButtonHandler))
//        navigationItem.rightBarButtonItem = rightBarButton
//    }
//
//    @objc func rightBarButtonHandler() {
//        collectionView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
//
//        if layoutType == 3 {
//            layoutType = 1
//        } else {
//            layoutType += 1
//        }
//
//        self.collectionView.setCollectionViewLayout(self.createLayout(with: layoutType), animated: true, completion: nil)
//    }
//}
//
//
//// MARK:- Search bar
//
//extension ViewController: UISearchBarDelegate {
//
//    // configure search controller
//    func configureSearchController() {
//        let searchResultsController = SearchResultsController()
//        let mapView = MKMapView()
//        searchResultsController.mapView = mapView
//        searchResultsController.delegate = self
//        searchController = UISearchController(searchResultsController: searchResultsController)
//        searchController?.searchResultsUpdater = searchResultsController
//        searchController?.isActive = true
//        searchController?.hidesNavigationBarDuringPresentation = false
//        searchController?.obscuresBackgroundDuringPresentation = false
//
//        definesPresentationContext = true
//        navigationItem.searchController = searchController
//    }
//
//    func configureSearchBar() {
//        // search bar attributes
//        let searchBar = searchController!.searchBar
//        searchBar.delegate = self
//        searchBar.autocapitalizationType = .none
//        searchBar.sizeToFit()
//        searchBar.tintColor = .black
//        searchBar.searchBarStyle = .minimal
//
//        // set the search bar height
//        let size = CGSize(width: 1, height: 50)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        let image = renderer.image { (_) in
//            UIColor.white.setFill()
//            let rect = UIBezierPath(rect: CGRect(origin: .zero, size: size))
//            rect.fill()
//        }
//        searchBar.setSearchFieldBackgroundImage(image, for: .normal)
//
//        // search text field attributes
//        let searchTextField = searchBar.searchTextField
//        searchTextField.borderStyle = .none
//        searchTextField.layer.cornerRadius = 8
//        searchTextField.layer.borderWidth = 1
//        searchTextField.layer.borderColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor
//        searchTextField.frame = CGRect(origin: .zero, size: size)
//
//        // cancel button location adjustment
//        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
//        cancelButton.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5), for: .default)
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        //        if webServiceManager == nil {
//        //            webServiceManager = WebServiceManager(packageId: packageId, urlString: urlString2)
//        //        } else {
//        //            webServiceManager.packageId = packageId
//        //            webServiceManager.urlString = urlString2
//        //        }
//        //
//        //        webServiceManager.useOfAPIRequest()
//
//    }
//
//    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
//        print("clicked")
//    }
//}
//
//// MARK:- AddressFetchDelegate
//
//extension ViewController: AddressFetchDelegate {
//    func didFetchAddress(_ address: MKPlacemark) {
//        print(address)
//    }
//}
//
//// MARK:- Create Layout
//extension ViewController {
//    /// Creates a grid layout for the collection view
//    /// - Parameter Int
//    /// - Throws None
//    /// - Returns UICollectionViewLayout
//    /// - Creates layouts dynamically, 1, 2, or 3 columns. Event from right bar button
//    private func createLayout(with layoutType: Int = 1) -> UICollectionViewLayout {
//        // group
//        var group: NSCollectionLayoutGroup!
//        switch layoutType {
//            case 1:
//                group = singleColumnLayout()
//            case 2:
//                group = doubleColumnLayout()
//            case 3:
//                group = tripleColumnLayout()
//            default:
//                break
//        }
//
//        // section
//        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 20
//        section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 20)
//
//        // section header
//        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
//        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: ViewController.sectionHeaderElementKind, alignment: .top)
//        sectionHeader.pinToVisibleBounds = true
//        sectionHeader.zIndex = 2
//        section.boundarySupplementaryItems = [sectionHeader]
//
//        // layout
//        let layout = UICollectionViewCompositionalLayout(section: section)
//        return layout
//    }
//
//    func singleColumnLayout() -> NSCollectionLayoutGroup {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
//
//        return group
//    }
//
//    func doubleColumnLayout() -> NSCollectionLayoutGroup {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//        return group
//    }
//
//    func tripleColumnLayout() -> NSCollectionLayoutGroup {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.4))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//        return group
//    }
//}
//
//// MARK:- Hierarchy and dataSource
//extension ViewController {
//    /// Creates a collection view
//    /// - Parameter None
//    /// - Throws None
//    /// - Returns Void
//    /// - Creates a collection view and adds it to the main view as a subview
//    func configureHierarchy() {
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout(with: layoutType))
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .systemBackground
//        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//    }
//
//    /// DataSource for the collection view
//    /// - Parameter None
//    /// - Throws None
//    /// - Returns Void
//    /// - Takes the result of the API call and applys it to the data source
//    func configureDataSource() {
//        let cellRegistration = UICollectionView.CellRegistration<MenuCell, CatalogueQualityScores>{ (cell, indexPath, data) in
//            cell.label.text = data.package
//            cell.contentView.backgroundColor = .white
//            cell.contentView.shadowBorder()
//            cell.label.textAlignment = .center
//            cell.label.font = UIFont.preferredFont(forTextStyle: .subheadline)
//            cell.label.textColor = .lightGray
//        }
//
//        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: ViewController.sectionHeaderElementKind) {
//            (supplementaryView, string, indexPath) in
//            if let snapshot = self.snapshot {
//                supplementaryView.label.text = snapshot.sectionIdentifiers[indexPath.section]
//                supplementaryView.label.textColor = .gray
//                supplementaryView.layer.cornerRadius = 10
//            }
//        }
//
//        dataSource = UICollectionViewDiffableDataSource<String, CatalogueQualityScores>(collectionView: collectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, identifier: CatalogueQualityScores) -> UICollectionViewCell? in
//            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
//        })
//
//        dataSource.supplementaryViewProvider = { (view, kind, index) in
//            self.supplementaryView = self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
//            self.Y_OF_HEADER_VIEW = self.supplementaryView.bounds.origin.y
//            return self.supplementaryView
//        }
//
//        snapshot = NSDiffableDataSourceSnapshot<String, CatalogueQualityScores>()
//        snapshot.appendSections(["Recently modified data"])
//    }
//}
//
//// MARK: - Request next data set
//
//extension ViewController {
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
//            updateNextSet()
//        }
//    }
//
//    func updateNextSet(){
//        offsetBy += 1
//        print("num", offsetBy)
//        configureAPIRequest(offsetBy: offsetBy)
//        DispatchQueue.main.async(execute: collectionView.reloadData)
//    }
//}
//
//// MARK: - API request
//extension ViewController {
//    /// Create an API request
//    /// - Parameter None
//    /// - Throws None
//    /// - Returns Void
//    /// - Create an API request to the Catalogue Quality Scores
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/resource_search?query=name:aboriginal
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=tags:economy
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?q=59de0a7d-86d0-40a3-80b8-75d213e902ab
//    /// https://open.toronto.ca/dataset/catalogue-quality-scores/
//    func configureAPIRequest(offsetBy: Int = 0) {
//        //        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search?id=7b2830a7-1483-451f-8681-ef4942eedc34"
//        //        let paramters = ["id": "22f223e7-73f7-4842-935c-80a0ba5c3e5b", "limit": "10"]
//        let OFFSET_CONSTANT = 20
//        print("total", String(OFFSET_CONSTANT * offsetBy))
//        //        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/recently_changed_packages_activity_list"
//        //        let parameters: [String: String] = ["limit": "20", "offset": String(OFFSET_CONSTANT * offsetBy)]
//
//        //        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=473def30-1c87-45f1-95c4-06b9bf693fec"
//        let urlString = "https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search"
//        //        var parameters: [String: String]?
//        let parameters: [String: String] = ["id": "22f223e7-73f7-4842-935c-80a0ba5c3e5b", "limit": "5", "offset": String(OFFSET_CONSTANT * offsetBy)]
//
//        webServiceManager = WebServiceManager()
//        webServiceManager.sendRequest(urlString, parameters: parameters) { (responseObject, error) in
//            guard let responseObject = responseObject, error == nil else {
//                print(error?.localizedDescription ?? "Unknown error")
//                return
//            }
//
//            //            latest updates
//            //            print(responseObject)
//            //            if let result = responseObject["result"] as? [String: Any] {
//            //                print("result", result)
//            //            }
//
//            //            if let result = responseObject["result"] as? [[String: Any]] {
//            //                result.forEach { (package) in
//            //                    if let data = package["data"] as? [String: Any], let package = data["package"] as? [String: Any], let title = package["title"] as? String {
//            //                        self.snapshot.appendItems([Package(title: title)])
//            //                    }
//            //                }
//            //            }
//
//            //              tag_list?
//            //            if let result = responseObject["result"] as? [String: Any] {
//            //                // parse all the fields
//            //                if let fields = result["fields"] as? [[String: Any]] {
//            //
//            //                    fields.forEach { (field) in
//            //                        let f = Field(id: field["id"] as? String, info: field["info"] as? [String: String], type: field["type"] as? String)
//            //                        self.fieldsArr.append(f)
//            //                    }
//            //                }
//            //
//            //                // parse the content of the API fetch to be displayed
//
//            if let result = responseObject["result"] as? [String: Any],  let finalResult = result["records"] as? [[String: Any]] {
//                //                    print(finalResult)
//                finalResult.forEach { (catalogue) in
//                    if let package = catalogue["package"] as? String {
//                        self.snapshot.appendItems([CatalogueQualityScores(package: package)])
//                        //                            self.resultArr.append(CatalogueQualityScores(grade_norm: medal))
//                    }
//                }
//            }
//            //            }
//
//            self.dataSource.apply(self.snapshot, animatingDifferences: false)
//        }
//    }
//}
//

//
//struct Package: Hashable {
//    let url: String? = nil
//    let authorEmail: String? = nil
//    let id: String? = nil
//    let name: String? = nil
//    let version: String? = nil
//    let license_id: String? = nil
//    let notes: String? = nil
//    let author: String? = nil
//    let isPrivate: Int? = nil
//    let maintainer: String? = nil
//    let creatorUserId: String? = nil
//    let metadataCreated: String? = nil
//    let metadataModified: Date? = nil
//    let type: String? = nil
//    let revisionId: String? = nil
//    let title: String?
//    let ownerOrg: String? = nil
//    let state: String? = nil
//    let identifier = UUID()
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(identifier)
//    }
//}
//
//enum Medal: String {
//    case Gold, Silver, Bronze
//}
//
//struct Field {
//    let id: String? // name of the field
//    let info: [String: String]? // label, notes, type_override
//    let type: String? // i.e. float8
//}
//
//
////if let result = responseObject["result"] as? [String: Any] {
////    // parse all the fields
////    if let fields = result["fields"] as? [[String: Any]] {
////
////        fields.forEach { (field) in
////            let f = Field(id: field["id"] as? String, info: field["info"] as? [String: String], type: field["type"] as? String)
////            self.fieldsArr.append(f)
////        }
////    }
////
////    // parse the content of the API fetch to be displayed
////    if let finalResult = result["records"] as? [[String: Any]] {
////        print(finalResult)
////        finalResult.forEach { (catalogue) in
////            if let package = catalogue["package"] as? String {
////                self.snapshot.appendItems([CatalogueQualityScores(package: package)])
////                //                            self.resultArr.append(CatalogueQualityScores(grade_norm: medal))
////            }
////        }
////    }
////}


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


//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=civic_issues:"Poverty reduction"+dataset_category:"Document"

//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=state:%22active%22%20AND%20civic_issues:%22Poverty%20reduction%22
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=tags:%22aboriginal%22%20AND%20civic_issues:%22Poverty%20reduction%22
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=filter(state:%22active%22)+filter(civic_issues:%22Poverty%20reduction%22)
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=name:%22solid-waste-management-services-transfer-station-location+dataset_category:%22Document%22
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=civic_issues:%22Poverty%20reduction%22+dataset_category:%22Document%22
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/resource_search?query=name:aboriginal
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=tags:economy
// https:/ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=7e038ff9-b616-4070-9753-6f493b2cdbb0
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?q=59de0a7d-86d0-40a3-80b8-75d213e902ab
// this provides the list of civic issues
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?facet.field=[%22civic_issues%22]&rows=0
// individual civic issue
// https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=civic_issues:%22Poverty%20reduction%22
// mlutiple queries
// https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?q=Environment,poverty
// mapJson, the ID is from https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=a154790c-4a8a-4d09-ab6b-535ddb646770 search and
// from the "resources" key's "id"
//https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/datastore_search?id=e25e9460-a0e8-469c-b9fb-9a4837ac6c1c
// metadata modified desc
// https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?q=Environment,poverty&sort=metadata_modified%20desc

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


//////////////////////////////////////////////
// results update

//
//  ViewController + ResultsUpdate.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//
/*
 Abstract:
 UISearchResultsUpdating protocol is a set of methods that let you update search results based on information the user enters into the search bar.
 It makes use of two things:
 1) the text from the search bar text field
 2) the token(s) from the search bar text field
 Given these two, the search results are updated on SearchResultsController.
 */

//import UIKit
//
//extension ViewController: UISearchResultsUpdating {
//    
//    // MARK:- updateSearchResults
//    // Called when the search bar's text has changed or when the search bar becomes first responder.
//    
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }
//        
//        // fetch the API from one of SearchCategories as long as a token is selected and the text field is empty
//        if text.isEmpty, !searchController.searchBar.searchTextField.tokens.isEmpty  {
//            suggestArray.removeAll()
//            
//            let searchTextField = searchController.searchBar.searchTextField
//            let searchToken = searchTextField.tokens[searchTextField.tokens.count - 1]
//            if let searchTokenValue = searchToken.representedObject as? NSNumber {
//                let suggestedSearch = SearchCategories.allCases[searchTokenValue.intValue]
//                fetchAndParse(suggestedSearch: suggestedSearch)
//            } else if let searchTokenValue = searchToken.representedObject as? SearchCategoriesWithQuery {
//                fetchWithQueryAndParse(searchCategory: searchTokenValue)
//            }
//        }else {
//            // now that we have the list from the selected token, we can further filter the list
//            var filtered = suggestArray
//            
//            // Strip out all the leading and trailing spaces.
//            let whitespaceCharacterSet = CharacterSet.whitespaces
//            let strippedString = text.trimmingCharacters(in: whitespaceCharacterSet).lowercased()
//            let searchItems = strippedString.components(separatedBy: " ") as [String]
//            
//            // Filter results down by matching words. Can include multiple properties if the data type has them.
//            var curTerm = searchItems[0]
//            var idx = 0
//            while curTerm != "" {
//                filtered = filtered.filter { $0.title.lowercased().contains(curTerm) }
//                idx += 1
//                curTerm = (idx < searchItems.count) ? searchItems[idx] : ""
//            }
//            
//            // Apply the filtered results to the search results table.
//            loadSearchControllerData(with: filtered)
//        }
//    }
//    
//    // MARK:- fetchAndParse
//    
//    func fetchAndParse(suggestedSearch: SearchCategories) {
//        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
//        
//        
//        switch suggestedSearch {
//            case .tags:
//                <#code#>
//            default:
//                <#code#>
//        }
//        
//        WebServiceManager.shared.sendRequest(urlString: <#T##String#>, parameters: <#T##[QueryKey : String]?#>, completion: <#T##([String : Any]?, Error?) -> Void#>)
//        
//        suggestedSearch.fetchAPI(url: suggestedSearch.url , parameters: nil) { (responseObject, error) in
//            guard let responseObject = responseObject, error == nil else {
//                print("fetch and parse error",error?.localizedDescription ?? "Unknown error")
//                self.showAlertController(error: error)
//                return
//            }
//            
//            switch suggestedSearch {
//                case .tags:
//                    if let results = responseObject["result"] as? [String] {
//                        let fetchedDataArr = results.map { FetchedData(title: $0, searchCategories: suggestedSearch, parameters: [suggestedSearch.queryKey: $0])}
//                        self.suggestArray += fetchedDataArr
//                    }
//                    self.loadSearchControllerData(with: self.suggestArray)
//                    
//                    // when the token is deleted by backspace, the no row is selected, which means there is no change for the showSuggestedSearches to be toggled.
//                    DispatchQueue.main.async {
//                        self.searchResultsController.showSuggestedSearches = .additionalSuggest
//                    }
//                case .packages:
//                    if let results = responseObject["result"] as? [String] {
//                        print("results", results)
//                        let fetchedDataArr = results.map { FetchedData(title: $0, searchCategories: suggestedSearch, parameters: [suggestedSearch.queryKey: $0])}
//                        self.suggestArray += fetchedDataArr
//                    }
//                    self.loadSearchControllerData(with: self.suggestArray)
//                case .recentlyChanged:
//                    if let results = responseObject["result"] as? [[String: Any]] {
//                        results.forEach { (package) in
//                            if let data = package["data"] as? [String: Any],
//                               let package = data["package"] as? [String: Any],
//                               let title = package["title"] as? String,
//                               let id = package["id"] as? String {
//                                let parameters: [QueryKey: String] = [suggestedSearch.queryKey: id]
//                                let fetchedData = FetchedData(title: title, searchCategories: suggestedSearch, parameters: parameters)
//                                self.suggestArray.append(fetchedData)
//                            }
//                        }
//                    }
//                    self.loadSearchControllerData(with: self.suggestArray)
//                case .qualityScores:
//                    if let result = responseObject["result"] as? [String: Any], let records = result["records"] as? [[String: Any]] {
//                        records.forEach { (catalogue) in
//                            if let package = catalogue["package"] as? String {
//                                let fetchedData = FetchedData(title: package, searchCategories: suggestedSearch, parameters: [suggestedSearch.queryKey: package])
//                                self.suggestArray.append(fetchedData)
//                            }
//                        }
//                    }
//                    self.loadSearchControllerData(with: self.suggestArray)
//            }
//        }
//    }
//    
//    // MARK: - Alert controller
//    
//    func showAlertController(error: Error?) {
//        navigationController?.activityStopAnimating()
//        DispatchQueue.main.async {
//            let alertController = UIAlertController(title: "Network Error", message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
//                if let searchField = self.navigationItem.searchController?.searchBar.searchTextField {
//                    var count = searchField.tokens.count
//                    while count > 0 {
//                        searchField.removeToken(at: count - 1)
//                        count -= 1
//                    }
//                }
//            }))
//            self.present(alertController, animated: true, completion: nil)
//        }
//    }
//    
//    // MARK: - fetch with query and parse
//    // https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=tags:economy
//    
//    func fetchWithQueryAndParse(searchCategory: SearchCategoriesWithQuery) {
//        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
//        searchCategory.fetchAPI(url: searchCategory.urlWithQuery, parameters: searchCategory.parameters) { (responseObject, error) in
//            guard let responseObject = responseObject, error == nil else {
//                print("fetchWithQueryAndParse error",error?.localizedDescription ?? "Unknown error")
//                self.showAlertController(error: error)
//                return
//            }
//            
//            if let result = responseObject["result"] as? [String: Any], let results = result["results"] as? [[String: Any]] {
//                results.forEach { (item) in
//                    if let title = item["title"] as? String, let id = item["id"] as? String {
//                        // https:/ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=7e038ff9-b616-4070-9753-6f493b2cdbb0
//                        let fetchedData = FetchedData(title: title, queryValue: id)
//                        self.suggestArray.append(fetchedData)
//                    }
//                }
//                self.loadSearchControllerData(with: self.suggestArray)
//            }
//        }
//    }
//    
//    // MARK:- loadSearchControllerData
//    
//    /// Loads the search results controller
//    /// - Parameter `[Stirng]` The array of fetched data from the API request
//    /// - Parameter `SearchCategories`  The enum type is passed to the search results controller for didSelectRowAt. It's required for ItemDetailViewcontroller to make an appropriate API request.
//    /// - Throws None
//    /// - Returns `Void`
//    /// - Loads the search results controller with the data fetched from the API request as well as the SearchCategories.
//    
//    func loadSearchControllerData(with fetchedDataArr: [FetchedData]) {
//        DispatchQueue.main.async {
//            if let searchResultsController = self.searchController.searchResultsController as? SearchResultsController {
//                self.navigationController?.activityStopAnimating()
//                searchResultsController.fetchedDataArr = fetchedDataArr
//                searchResultsController.tableView.reloadData()
//            }
//        }
//    }
//}
//

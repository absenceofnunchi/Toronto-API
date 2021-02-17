//
//  ItemDetailViewController.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//
/*
 Abstract:
 SearchResultsController passes a value through a token to ViewController and ViewController passes the fetched data from API to ItemDetailViewController.
 ItemDetailViewController displays the data and also pushes additional view controllers (ExpandDetail or ExpandTable) for details
 */

import UIKit
import SwiftyJSON

class ItemDetailViewController: UITableViewController {
    
    // MARK:- Properties
    
    var fetchedData: FetchedData!
    var dataSourceDelegate: FavouritesDataSource?
    private var data = [(String, AnyObject)]()
    private var url: URL!
    private var shareButton: UIBarButtonItem!
    private var favouriteButton: UIBarButtonItem!
    private let defaults = UserDefaults.standard
    private var unarchivedData = [FetchedData]()
    private var isAlreadyFavourited = false
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        if let fetchedData = fetchedData {
            fetchAPI()
            title = fetchedData.title
        }
        configureNavigationItems()
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.itemDetailCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - fetchAPI

extension ItemDetailViewController {
    // tag: https:/ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=7e038ff9-b616-4070-9753-6f493b2cdbb0
    // package: https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=name:solid-waste-management-services-transfer-station-locations
    // topic(): https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show
    // civic: https://ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_search?fq=civic_issues:%22Poverty%20reduction%22
    func fetchAPI() {
        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        
        var urlString: String!
        var parameters = [String: String]()
        if let fetchedData = fetchedData, let params = fetchedData.parameters {
            for (key, value) in params {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        switch fetchedData.searchCategories {
            case .tag(_), .qualityScores, .recentlyChanged, .topic(_):
                urlString = URLScheme.baseURL + Query.ActionType.packageShow
            case .packages, .civicIssues, .packageAutocomplete:
                urlString = URLScheme.baseURL + Query.ActionType.packageSearch
            case .admins:
                urlString = URLScheme.baseURL + Query.ActionType.userShow
            case .vocabularyList:
                urlString = URLScheme.baseURL + Query.ActionType.vocabularyList
            case .helpShow:
                urlString = URLScheme.baseURL + Query.ActionType.helpShow
            default:
                break
        }
        
        guard urlString != nil else {
            DispatchQueue.main.async {
                self.navigationController?.activityStopAnimating()
                let alertController = UIAlertController(title: "Network Error", message: "Please try again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            return
        }
        
        WebServiceManager.shared.sendRequest(urlString: urlString, parameters: parameters) { (responseObject, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                    let alertController = UIAlertController(title: "Network Error", message: error.localizedDescription , preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            if let responseObject = responseObject {
                let json = JSON(responseObject as [String: Any])
                let myDictionary = self.json2dic(json)
                
//                switch fetchedData.searchCategories {
//                    case <#pattern#>:
//                        <#code#>
//                    default:
//                        <#code#>
//                }
                if let result = myDictionary["result"] as? [String: AnyObject] {
                    let resultArr = result.map { $0 }.sorted { $0.key < $1.key }
                    self.data.append(contentsOf: resultArr)
                } else if let result = myDictionary["result"] as? String {
                    if let definition = ("Overview", result) as? (String, AnyObject) {
                        self.data.append(definition)
                    }
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                    let alertController = UIAlertController(title: "No Data", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        self.navigationController?.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

// MARK: - Datasource

extension ItemDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let detail = data[section]
        if detail.1 is [String: AnyObject] {
            let arr = (detail.1 as! [String: AnyObject]).map { $0 }.sorted { $0.key < $1.key }
            let value = arr as [(String, AnyObject)]
            if value.count > 0 {
                return value.count
            }
        }
        
        return 1
    }
    
    /// The types to display are either [String: String] , [String: [String: String]] or [String: String: [String: String]]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.itemDetailCell, for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        let detail = data[indexPath.section]
        if detail.1 is [String: AnyObject] {
            let arr = (detail.1 as! [String: AnyObject]).map { $0 }.sorted { $0.key < $1.key }
            let value = arr as [(String, AnyObject)]
            if value.count > 0 {
                if let text = value[indexPath.row].1 as? String {
                    cell.textLabel?.text = value[indexPath.row].0 + ": " + text
                } else {
                    var text: String!
                    if value[indexPath.row].1 is Dictionary<String, Any> {
                        text = value[indexPath.row].0
                        cell.accessoryType = .disclosureIndicator
                    } else {
                        text = value[indexPath.row].0 + ": null"
                    }
                    cell.textLabel?.text = text
                }
            }
        } else {
            cell.textLabel?.text = detail.1 as? String
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var header: String!
        var body: String! = nil
        var detailDict: [String: AnyObject]! = nil
        var itemInfoType: ItemInfoType = .noType
        
        let detail = data[indexPath.section]
        if detail.1 is [String: AnyObject] {
            let arr = (detail.1 as! [String: AnyObject]).map { $0 }.sorted { $0.key < $1.key }
            let value = arr as [(String, AnyObject)]
            if value.count > 0 {
                if let text = value[indexPath.row].1 as? String {
                    header = value[indexPath.row].0
                    body = text
                    itemInfoType = .labelAndTextView
                } else {
                    if let dict = value[indexPath.row].1 as? Dictionary<String, AnyObject> {
                        header = value[indexPath.row].0
                        detailDict = dict
                        itemInfoType = .dict
                    } else {
                        body = "null"
                        itemInfoType = .noType
                    }
                }
            }
        } else {
            body = detail.1 as? String
            itemInfoType = .textViewOnly
        }
        
        let itemInfo = ItemInfo(header: header, body: body, dict: detailDict, itemInfoType: itemInfoType)
        if itemInfoType == .dict {
            let expandTableVC = ExpandTableViewController()
            expandTableVC.itemInfo = itemInfo
            self.navigationController?.pushViewController(expandTableVC, animated: true)
        } else {
            let expandDetailVC = ExpandDetailViewController()
            expandDetailVC.itemInfo = itemInfo
            self.navigationController?.pushViewController(expandDetailVC, animated: true)
        }
    }
    
    func navigate(to vc: UIViewController) {
        guard let windowInterfaceOrientation = ItemDetailViewController.windowInterfaceOrientation else { return }
        if windowInterfaceOrientation.isLandscape {
            self.showDetailViewController(vc, sender: self)
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Navigation Items

extension ItemDetailViewController {
    func configureNavigationItems() {
        self.edgesForExtendedLayout = []

        do {
            if let savedFavourites = defaults.object(forKey: Keys.favourites) as? Data {
                let decoded = try JSONDecoder().decode([FetchedData].self, from: savedFavourites)
                unarchivedData.removeAll()
                unarchivedData = decoded
                for data in decoded where data.title == fetchedData.title {
                    isAlreadyFavourited = true
                }
            }
        } catch (let error){
            print(error)
        }
        
        setNavigationItems()
    }

    @objc func buttonHandler(_ sender: UIButton) {
        switch sender.tag {
            case 1:
                guard let url = self.url else { return }
                let shareSheetVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                present(shareSheetVC, animated: true, completion: nil)
                
                if let pop = shareSheetVC.popoverPresentationController {
                    pop.sourceView = self.view
                    pop.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                    pop.permittedArrowDirections = []
                }
            case 2:
                if isAlreadyFavourited {
                    // delete if it already exists
                    unarchivedData.removeAll { $0.title == fetchedData.title }
                } else {
                    // only save if it doesn't already exist
                    unarchivedData.append(fetchedData)
                }
                
                defaults.removeObject(forKey: Keys.favourites)

                do {
                    let archived = try JSONEncoder().encode(unarchivedData)
                    defaults.set(archived, forKey: Keys.favourites)
                    defaults.synchronize()
                } catch (let error) {
                    print("archiving error: \(error)")
                }
                
                isAlreadyFavourited.toggle()
                setNavigationItems()
                
                dataSourceDelegate?.configureInitialData()
            default:
                break
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setNavigationItems()
    }
    
    func setNavigationItems() {
        let actionImage = UIImage(systemName: "square.and.arrow.up")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysTemplate)
        let starImage = UIImage(systemName: isAlreadyFavourited ? "star.fill" : "star")
        
        shareButton = UIBarButtonItem(image: actionImage, style: .plain, target: self, action: #selector(buttonHandler(_:)))
        shareButton.tag = 1
        
        favouriteButton = UIBarButtonItem(image: starImage, style: .plain, target: self, action: #selector(buttonHandler(_:)))
        favouriteButton.tag = 2
        if UIDevice.current.orientation.isLandscape {
            shareButton.tintColor = .lightGray
            favouriteButton.tintColor = isAlreadyFavourited ? .yellow : .lightGray
        } else {
            shareButton.tintColor = .white
            favouriteButton.tintColor = isAlreadyFavourited ? .yellow : .white
        }
        
        navigationItem.rightBarButtonItems = [shareButton, favouriteButton]
    }
}

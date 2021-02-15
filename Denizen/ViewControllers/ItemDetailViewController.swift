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
    var data = [(String, AnyObject)]()
    var url: URL!

    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(urlFetched), name: .urlFetched, object: nil)
        
        configureTableView()
        fetchAPI()
        configureShareButton()
        
        title = fetchedData.title
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .urlFetched, object: nil)
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
        if let params = fetchedData.parameters {
            for (key, value) in params {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        switch fetchedData.searchCategories {
            case .tag(_), .qualityScores, .recentlyChanged, .topic(_):
                urlString = URLScheme.baseURL + Query.ActionType.packageShow
            case .packages, .civicIssues:
                urlString = URLScheme.baseURL + Query.ActionType.packageSearch
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
                if let result = myDictionary["result"] as? [String: AnyObject] {
                    let resultArr = result.map { $0 }.sorted { $0.key < $1.key }
                    self.data.append(contentsOf: resultArr)
                    DispatchQueue.main.async {
                        self.navigationController?.activityStopAnimating()
                        self.tableView.reloadData()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.activityStopAnimating()
                    let alertController = UIAlertController(title: "No Data", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (_) in
                        self.navigationController?.popViewController(animated: true)
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
//                    let text = value[indexPath.row].0 + ": " + text
//                    let mas = NSMutableAttributedString(string: text)
//                    let range = (mas.string as NSString).range(of: value[indexPath.row].0)
//                    mas.addAttributes([.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)], range: range)
                    
                    cell.textLabel?.text = value[indexPath.row].0 + ": " + text
                } else {
                    
                    var text: String!
                    if value[indexPath.row].1 is Dictionary<String, Any> {
                        text = value[indexPath.row].0
                        cell.accessoryType = .disclosureIndicator
                    } else {
                        text = value[indexPath.row].0 + ": null"
                    }
                    
//                    let mas = NSMutableAttributedString(string: text)
//                    let range = (mas.string as NSString).range(of: value[indexPath.row].0)
//                    mas.addAttributes([.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)], range: range)
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

// MARK: - Share button

extension ItemDetailViewController {
    func configureShareButton() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        shareButton.tintColor = UIColor(red: 175/255, green: 122/255, blue: 197/255, alpha: 1)
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func share(_ sender: UIButton) {
        guard let url = self.url else { return }
        let shareSheetVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(shareSheetVC, animated: true, completion: nil)
        
        if let pop = shareSheetVC.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }
    }
    
    @objc func urlFetched(notification: NSNotification) {
        if let fetchedURL = notification.userInfo?["url"] as? URL {
            self.url = fetchedURL
        }
    }
}

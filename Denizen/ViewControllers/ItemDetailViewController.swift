//
//  ItemDetailViewController.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//

import UIKit
import SwiftyJSON

class ItemDetailViewController: UITableViewController {
    
    // MARK:- Properties
    
    var fetchedData: FetchedData!
    var data = [(String, AnyObject)]()

    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        fetchAPI()
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.itemDetailCell)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ItemDetailViewController {
    // https:/ckan0.cf.opendata.inter.prod-toronto.ca/api/3/action/package_show?id=7e038ff9-b616-4070-9753-6f493b2cdbb0
    func fetchAPI() {
        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        WebServiceManager.shared.sendRequest(urlString: URLScheme.baseURL + ActionType.packageShow.rawValue, parameters: [QueryKey.id: fetchedData.queryValue ?? ""]) { (responseObject, error) in
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
                print("no data")
            }

        }
    }
    
    func json2dic(_ j: JSON) -> [String:AnyObject] {
        var post = [String:AnyObject]()
        for (key, object) in j {
            post[key] = object.stringValue as AnyObject
            if object.stringValue == "" {
                post[key] = json2dic(object) as AnyObject
            }
        }
        return post
    }
}

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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.itemDetailCell, for: indexPath)
        cell.selectionStyle = .none
        
        let detail = data[indexPath.section]
        if detail.1 is [String: AnyObject] {
            let arr = (detail.1 as! [String: AnyObject]).map { $0 }.sorted { $0.key < $1.key }
            print("arr", arr)
            let value = arr as [(String, AnyObject)]
            if value.count > 0 {
                if let text = value[indexPath.row].1 as? String {
                    cell.textLabel?.text = value[indexPath.row].0 + ": " + text
                } else {
                    cell.textLabel?.text = value[indexPath.row].0 + ": null"
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
        var body: String!
        
        let detail = data[indexPath.section]
        if detail.1 is [String: AnyObject] {
            let arr = (detail.1 as! [String: AnyObject]).map { $0 }.sorted { $0.key < $1.key }
            let value = arr as [(String, AnyObject)]
            if value.count > 0 {
                if let text = value[indexPath.row].1 as? String {
                    header = value[indexPath.row].0
                    body = text
                } else {
                    header = value[indexPath.row].0
                    body = "null"
                }
            }
        } else {
            body = detail.1 as? String
        }
        
        let expandDetailVC = ExpandDetailViewController()
        let itemInfo = ItemInfo(header: header, body: body)
        expandDetailVC.itemInfo = itemInfo
        navigationController?.pushViewController(expandDetailVC, animated: true)
    }
}


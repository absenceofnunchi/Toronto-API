//
//  ExpandTableViewController.swift
//  Denizen
//
//  Created by J C on 2021-01-31.
//

import UIKit

class ExpandTableViewController: UITableViewController {
    var itemInfo: ItemInfo?
    var data: [(String, AnyObject)]!
    var resourceId: String!
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Resource Detail"
        self.edgesForExtendedLayout = []

        configure()
    }
    
    func configure() {
        if let dict = itemInfo?.dict {
            if dict.isEmpty {
                let alertController = UIAlertController(title: "No Data", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))

                self.present(alertController, animated: true, completion: nil)
            } else {
                title = itemInfo?.header ?? ""
                data = dict.map { $0 }.sorted { $0.key < $1.key }
            }
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.itemDetailCell)
    }
}

// MARK: - Table view data source

extension ExpandTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 0
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.itemDetailCell, for: indexPath)
        cell.selectionStyle = .none

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
            let text = detail.1 as? String
            cell.textLabel?.text = text
            
            if text == "GeoJSON" {
                for (key, value) in data {
                    if key == "id" {
                        if let resourceId = value as? String {
                            self.resourceId = resourceId
                            configureNavigationItem()
                        }
                    }
                }
            }
        }
        return cell
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
            navigationController?.pushViewController(expandTableVC, animated: true)
        } else {
            let expandDetailVC = ExpandDetailViewController()
            expandDetailVC.itemInfo = itemInfo
            navigationController?.pushViewController(expandDetailVC, animated: true)
        }
    }
}

extension ExpandTableViewController {
    func configureNavigationItem() {
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "map"), style: .plain, target: self, action: #selector(barButtonHandler))
        rightBarButton.tintColor = .lightGray
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func barButtonHandler() {
        let mapVC = MapViewController()
        mapVC.resourceId = self.resourceId
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
}

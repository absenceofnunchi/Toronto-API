//
//  MapTableViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-07.
//

import UIKit

class MapTableViewController: UITableViewController {
    var data: [(String, AnyObject)]!
    
    override func loadView() {
        super.loadView()
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Map Detail"
        
        configure()
    }
    
    func configure() {
        if let data = self.data {
            if data.isEmpty {
                let alertController = UIAlertController(title: "No Data", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.mapDetailCell)
    }
}

// MARK: - Table view data source

extension MapTableViewController {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.mapDetailCell, for: indexPath)
        cell.selectionStyle = .none

        if let text = data[indexPath.section].1 as? String {
            cell.textLabel?.text = text
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let body = data[indexPath.section].1 as? String {
            let title = data[indexPath.section].0
            let itemInfo = ItemInfo(header: title, body: body, dict: nil, itemInfoType: .labelAndTextView)
            let expandDetailVC = ExpandDetailViewController()
            expandDetailVC.itemInfo = itemInfo
            navigationController?.pushViewController(expandDetailVC, animated: true)
        }
    }
}

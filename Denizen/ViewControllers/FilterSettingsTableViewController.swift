//
//  FilterSettingsTableViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-02.
//

import UIKit

class FilterSettingsTableViewController: UITableViewController {
    var data: Filter!
    var parsedData = [String]()
    weak var delegate: FilterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        if data.title == .orderBy {
            configureSortMenu()
        } else {
            configureAPIRequest()
        }
    }
        
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.filterCell)
    }
}

// MARK: - API request

extension FilterSettingsTableViewController {
    func configureAPIRequest() {
        self.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
        let urlString = URLScheme.baseURL + Query.ActionType.packageSearch
        let parameters = [Query.Key.facetField: "[\"\(data.title.facet)\"]", Query.Key.rows: "0"]

        WebServiceManager.shared.sendRequest(urlString: urlString, parameters: parameters) { (responseObject, error) in
            guard let responseObject = responseObject, error == nil else {
                print("fetch and parse error",error?.localizedDescription ?? "Unknown error")
                DispatchQueue.main.async {
                    self.activityStopAnimating()
                    let alertController = UIAlertController(title: "Network Error", message: error?.localizedDescription ?? "Unknown Error", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: {_ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            self.parse(responseObject: responseObject, facet: self.data.title.facet)
        }
    }
    
    func parse(responseObject: [String: Any], facet: String) {
        if let result = responseObject["result"] as? [String: Any], let facets = result["facets"] as? [String: Any], let facetArr = facets[facet] as? [String: Any] {
            facetArr.forEach { (item) in
                parsedData.append(item.key)
            }
            
            DispatchQueue.main.async {
                self.activityStopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    func configureSortMenu() {
        parsedData = ["metadata_modified desc", "metadata_modified asc"]
    }
}

// MARK: - Table view data source

extension FilterSettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parsedData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
        cell.textLabel?.text = parsedData[indexPath.row]
        return cell
    }
}

// MARK: - Table view delegate

extension FilterSettingsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedData = parsedData[indexPath.row]
        delegate?.didSelectFilter(selectedFilter: data, setting: selectedData)
        self.navigationController?.popViewController(animated: true)
    }
}



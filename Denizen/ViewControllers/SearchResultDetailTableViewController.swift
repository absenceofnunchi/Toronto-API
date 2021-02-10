//
//  SearchResultDetailTableViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-08.
//

import UIKit

class SearchResultDetailTableViewController: UITableViewController {
    var fetchedDataArr: [FetchedData]!
    weak var suggestedSearchDelegate: SuggestedSearch?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.searchResultTableCell)
    }
}

// MARK: - Table view data source

extension  SearchResultDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedDataArr?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.searchResultTableCell)!
        
        let item = fetchedDataArr[indexPath.row].title
        configureCell(cell, forItemTitle: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let suggestedSearchDelegate = suggestedSearchDelegate else { return }

        tableView.deselectRow(at: indexPath, animated: true)


        
        // A product was selected; inform our delgete that a product was selected to view.
        let selected = fetchedDataArr[indexPath.row]
        suggestedSearchDelegate.didSelectItem(fetchedData: selected)
    }
}

//
//  SearchResultsController.swift
//  Denizen
//
//  Created by J C on 2021-01-20.
//

/*
 Abstract:
 Shows the results of a search from the ViewController's search bar.
 The result has two categories: token and the actual search result.
 Token is the search suggestions which includes tags, package, recently changed, etc.
 Token has to take place prior to the actual search result.
 */

import UIKit

class SearchResultsController: UITableViewController {
    // MARK: - Properties
    
    var items = [String]()
    weak var suggestedSearchDelegate: SuggestedSearch?
    
    // colors for the tokens
    class func suggestedColor(fromIndex: Int) -> UIColor {
        var suggestedColor: UIColor!
        switch fromIndex {
            case 0:
                suggestedColor = UIColor(red: 33/255, green: 1/255, blue: 95/255, alpha: 1)
            case 1:
                suggestedColor = UIColor(red: 175/255, green: 0/255, blue: 105/255, alpha: 1)
            case 2:
                suggestedColor = UIColor(red: 85/255, green: 179/255, blue: 177/255, alpha: 1)
            case 3:
                suggestedColor = UIColor(red: 246/255, green: 192/255, blue: 101/255, alpha: 1)
            default:
                break
        }
        
        return suggestedColor
    }
    
    // images for the tokens
    private func suggestedImage(fromIndex: Int) -> UIImage {
        let color = SearchResultsController.suggestedColor(fromIndex: fromIndex)
        return (UIImage(systemName: "magnifyingglass.circle.fill")?.withTintColor(color))!
    }
    
    // titles for the tokens
    class func suggestedTitle(fromIndex: Int) -> String {
        return suggestedSearches[fromIndex]
    }
    
    // categories i.e. tags, packages, quality score, etc
    static var suggestedSearches: [String] {
        var s = [String]()
        for category in SearchCategories.allCases {
            s.append(NSLocalizedString(category.rawValue, comment: ""))
        }
        return s
    }
    
    // To hide/show the suggested searches before and after a token is selected
    var showSuggestedSearches: Bool = false {
        didSet {
            if oldValue != showSuggestedSearches {
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - Table view data source

extension SearchResultsController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showSuggestedSearches ? SearchResultsController.suggestedSearches.count : items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return showSuggestedSearches ? NSLocalizedString("Suggested Searches", comment: "") : ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if showSuggestedSearches {
            let suggestedTitle = NSMutableAttributedString(string: SearchResultsController.suggestedSearches[indexPath.row])
            suggestedTitle.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: suggestedTitle.length))
            cell.textLabel?.attributedText = suggestedTitle
            
            let image = suggestedImage(fromIndex: indexPath.row)
            let tintableImage = image.withRenderingMode(.alwaysOriginal)
            cell.imageView?.image = tintableImage
        } else {
            let item = items[indexPath.row]
            configureCell(cell, forItemTitle: item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let suggestedSearchDelegate = suggestedSearchDelegate else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Make sure we are showing suggested searches before notifying which token was selected
        if showSuggestedSearches {
            // A suggested search was selected; inform our delegate that the selected search token was selected.
            let tokenToInsert = SearchResultsController.searchToken(tokenValue: indexPath.row)
            suggestedSearchDelegate.didSelectSuggestedSearch(token: tokenToInsert)
        } else {
            // A product was selected; inform our delgeate that a product was selected to view.
//            let selectedProduct = items[indexPath.row]
//            suggestedSearchDelegate.didSelectProduct(product: selectedProduct)
        }
    }
    
    // Given a table cell row number index, return its color number equivalent.
    class func colorKind(fromIndex: Int) -> Item.ColorKind {
        var colorKind: Item.ColorKind!
        switch fromIndex {
            case 0:
                colorKind = Item.ColorKind.red
            case 1:
                colorKind = Item.ColorKind.green
            case 2:
                colorKind = Item.ColorKind.blue
            case 3:
                colorKind = Item.ColorKind.yellow
            default:
                break
        }
        return colorKind
    }
    
    // Search a search token from an input value.
    class func searchToken(tokenValue: Int) -> UISearchToken {
        let tokenColor = SearchResultsController.suggestedColor(fromIndex: tokenValue)
        let image =
            UIImage(systemName: "circle.fill")?.withTintColor(tokenColor, renderingMode: .alwaysOriginal)
        let searchToken = UISearchToken(icon: image, text: suggestedTitle(fromIndex: tokenValue))
        
        // Set the color kind number as the token value.
        let color = SearchResultsController.colorKind(fromIndex: tokenValue).rawValue
        searchToken.representedObject = NSNumber(value: color)
        
        return searchToken
    }
}

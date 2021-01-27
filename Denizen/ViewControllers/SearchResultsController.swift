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
    
    var fetchedDataArr: [FetchedData]!
    weak var suggestedSearchDelegate: SuggestedSearch?
    
    // colors for the tokens
    class func suggestedColor(fromIndex: Int) -> UIColor {
        var suggestedColor: UIColor!
        switch fromIndex {
            case 0:
                suggestedColor = UIColor.red
            case 1:
                suggestedColor = UIColor.orange
            case 2:
                suggestedColor = UIColor.yellow
            case 3:
                suggestedColor = UIColor.green
            case 4:
                suggestedColor = UIColor.blue
            case 5:
                suggestedColor = UIColor.purple
            case 6:
                suggestedColor = UIColor.brown
            default:
                suggestedColor = UIColor.cyan
        }
        
        return suggestedColor
    }
    
    // categories i.e. tags, packages, quality score, etc
    var suggestedSearches: [String] {
        var s = [String]()
        
        if showSuggestedSearches == .additionalSuggest {
            for fetchedData in fetchedDataArr {
                s.append(fetchedData.title)
            }
        } else {
            for category in SearchCategories.allCases {
                s.append(NSLocalizedString(category.rawValue, comment: ""))
            }
        }

        return s
    }
    
    enum SearchState {
        case none, suggested, additionalSuggest
    }
    
    // To hide/show the suggested searches before and after a token is selected
    var showSuggestedSearches: SearchState = .none {
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
        switch showSuggestedSearches {
            case .suggested:
                return suggestedSearches.count
            case .none, .additionalSuggest:
                return fetchedDataArr.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch showSuggestedSearches {
            case .suggested:
                return NSLocalizedString("Suggested Searches", comment: "")
            case .none, .additionalSuggest:
                return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        switch showSuggestedSearches {
            case .suggested:
                let suggestedTitle = NSMutableAttributedString(string: suggestedSearches[indexPath.row])
                suggestedTitle.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: suggestedTitle.length))
                cell.textLabel?.attributedText = suggestedTitle
                
                let image = suggestedImage(fromIndex: indexPath.row)
                let tintableImage = image.withRenderingMode(.alwaysOriginal)
                cell.imageView?.image = tintableImage
            case .none, .additionalSuggest:
                let item = fetchedDataArr[indexPath.row].title
                configureCell(cell, forItemTitle: item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let suggestedSearchDelegate = suggestedSearchDelegate else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Make sure we are showing suggested searches before notifying which token was selected
        switch showSuggestedSearches {
            case .suggested, .additionalSuggest:
                // A suggested search was selected; inform our delegate that the selected search token was selected.
                let tokenToInsert = searchToken(tokenValue: indexPath.row)
                suggestedSearchDelegate.didSelectSuggestedSearch(token: tokenToInsert)
            case .none:
                // A product was selected; inform our delgeate that a product was selected to view.
                let selected = fetchedDataArr[indexPath.row]
                suggestedSearchDelegate.didSelectItem(fetchedData: selected)
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
    

}

// MARK: - Tokenize

extension SearchResultsController {
    // images for the tokens
    private func suggestedImage(fromIndex: Int) -> UIImage {
        let color = SearchResultsController.suggestedColor(fromIndex: fromIndex)
        return (UIImage(systemName: "magnifyingglass.circle.fill")?.withTintColor(color))!
    }
    
    // titles for the tokens
    func suggestedTitle(fromIndex: Int) -> String {
        return suggestedSearches[fromIndex]
    }
    
    // Search a search token from an input value.
    func searchToken(tokenValue: Int) -> UISearchToken {
        let tokenColor = SearchResultsController.suggestedColor(fromIndex: tokenValue)
        let image = UIImage(systemName: "circle.fill")?.withTintColor(tokenColor, renderingMode: .alwaysOriginal)
        let searchToken = UISearchToken(icon: image, text: suggestedTitle(fromIndex: tokenValue))
        
        // Set the color kind number as the token value.
//        let color = SearchResultsController.colorKind(fromIndex: tokenValue).rawValue
        searchToken.representedObject = NSNumber(value: tokenValue)
        
        return searchToken
    }
}

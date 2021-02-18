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
    let defaults = UserDefaults.standard

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
            case 7:
                suggestedColor = UIColor(red: 93/255, green: 109/255, blue: 126/255, alpha: 1)
            case 8:
                suggestedColor = UIColor(red: 245/255, green: 176/255, blue: 65/255, alpha: 1)
            default:
                suggestedColor = UIColor.cyan
        }

        return suggestedColor
    }

    let searchCategoryArr = [SearchCategories.tags, SearchCategories.packages, SearchCategories.qualityScores, SearchCategories.recentlyChanged, SearchCategories.topics, SearchCategories.civicIssues, SearchCategories.notices, SearchCategories.admins, SearchCategories.vocabularyList, SearchCategories.helpShow]

    // categories i.e. tags, packages, quality score, etc
    var suggestedSearches: [String] {
        var s = [String]()

        switch showSuggestedSearches {
            case .none, .additionalSuggest, .notices:
                if let fetchedDataArr = fetchedDataArr {
                    for fetchedData in fetchedDataArr {
                        s.append(fetchedData.title)
                    }
                }
            case .suggested:
                for category in searchCategoryArr {
                    s.append(NSLocalizedString(category.value, comment: ""))
                }
        }
        return s
    }

    lazy var filterButton: UIButton = {
        let filterButton = UIButton.systemButton(with: UIImage(systemName: "info.circle")!, target: self, action: #selector(filterButtonHandler))
        filterButton.tintColor = .systemRed
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(filterButton)

        let svflg = tableView.frameLayoutGuide
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor, constant: 8),
            filterButton.trailingAnchor.constraint(equalTo: svflg.trailingAnchor, constant: -8),
            filterButton.heightAnchor.constraint(equalToConstant: 35),
            filterButton.widthAnchor.constraint(equalToConstant: 65)
        ])

        return filterButton
    }()

    @objc func filterButtonHandler() {
        let alertController = UIAlertController(title: "", message: "The current search result being shown are filtered by your settings. Filters are not applicable to Packages, Quality Scores, Recently Changed, and Notices. Reset your filter settings to see the full result.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    // To hide/show the suggested searches before and after a token is selected
    lazy var showSuggestedSearches: SearchState = .none {
        didSet {
            if oldValue != showSuggestedSearches {
                tableView.reloadData()
            }

            switch showSuggestedSearches {
                case .suggested:
                    filterButton.isHidden = true
                default:
                    updateFilterButton()
            }
        }
    }

    func updateFilterButton() {
        var filterArr = [String]()
        for filter in FilterType.allCases {
            if let savedFilter = defaults.string(forKey: filter.rawValue) {
                filterArr.append(savedFilter)
            }
        }

        if filterArr.count > 0 {
            filterButton.isHidden = false
        } else {
            filterButton.isHidden = true
        }
    }

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Cell.searchResultCell)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - Table view data source

extension SearchResultsController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedSearches.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch showSuggestedSearches {
            case .suggested:
                return NSLocalizedString("Suggested Searches", comment: "")
            case .none, .additionalSuggest, .notices:
                return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.searchResultCell)!

        if SearchResultsController.windowInterfaceOrientation!.isLandscape {
            cell.selectionStyle = .gray
        }

        switch showSuggestedSearches {
            case .suggested:
                let suggestedTitle = NSMutableAttributedString(string: suggestedSearches[indexPath.row])
                suggestedTitle.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: suggestedTitle.length))
                cell.textLabel?.attributedText = suggestedTitle

                let image = suggestedImage(fromIndex: indexPath.row)
                let tintableImage = image.withRenderingMode(.alwaysOriginal)
                cell.imageView?.image = tintableImage
            case .none, .additionalSuggest, .notices:
                if let fetchedDataArr = fetchedDataArr, fetchedDataArr.count > 0 {
                    let item = fetchedDataArr[indexPath.row].title
                    cell.textLabel?.text = item
                    cell.imageView?.image = nil
                }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let suggestedSearchDelegate = suggestedSearchDelegate else { return }
//        tableView.deselectRow(at: indexPath, animated: true)

        // Make sure we are showing suggested searches before notifying which token was selected
        switch showSuggestedSearches {
            case .suggested:
                // A suggested search was selected; inform our delegate that the selected search token was selected.
                let tokenValue = searchCategoryArr[indexPath.row]
                let tokenToInsert = searchToken(searchCategory: tokenValue, index: indexPath.row)
                suggestedSearchDelegate.didSelectSuggestedSearch(token: tokenToInsert)
            case .additionalSuggest:
                if let fetchedDataArr = fetchedDataArr, fetchedDataArr.count > 0 {
                    let title = fetchedDataArr[indexPath.row].title
                    let searchCategory = fetchedDataArr[indexPath.row].searchCategories
                    let tokenToInsert = searchToken(searchCategory: searchCategory! ,title: title)
                    suggestedSearchDelegate.didSelectSuggestedSearch(token: tokenToInsert)
                }
            case .none:
                // A product was selected; inform our delgete that a product was selected to view.
                if let fetchedDataArr = fetchedDataArr, fetchedDataArr.count > 0 {
                    let selected = fetchedDataArr[indexPath.row]
                    suggestedSearchDelegate.didSelectItem(fetchedData: selected)
                }
            case .notices:
                if let fetchedDataArr = fetchedDataArr, fetchedDataArr.count > 0 {
                    let selected = fetchedDataArr[indexPath.row]
                    suggestedSearchDelegate.openWebView(fetchedData: selected)
                }
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
            case 4:
                colorKind = Item.ColorKind.orange
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

    // search token for the additional suggested search
    func searchToken(searchCategory: SearchCategories,title: String) -> UISearchToken {
        let tokenColor = SearchResultsController.suggestedColor(fromIndex: 6)
        let image = UIImage(systemName: "circle.fill")?.withTintColor(tokenColor, renderingMode: .alwaysOriginal)
        let searchToken = UISearchToken(icon: image, text: title)
        switch searchCategory {
            case .tags:
                let tag = SearchCategories.tag(title)
                searchToken.representedObject = tag
            case .topics:
                let topic = SearchCategories.topic(title)
                searchToken.representedObject = topic
            default:
                break
        }
        
        return searchToken
    }

    // Search a search token from an input value. This token is for the suggested search.
    func searchToken(searchCategory: SearchCategories, index: Int) -> UISearchToken {
        let tokenColor = SearchResultsController.suggestedColor(fromIndex: index)
        let image = UIImage(systemName: "circle.fill")?.withTintColor(tokenColor, renderingMode: .alwaysOriginal)
        let searchToken = UISearchToken(icon: image, text: searchCategory.value)

        searchToken.representedObject = searchCategory

        return searchToken
    }
}

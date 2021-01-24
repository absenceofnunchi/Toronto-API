
import UIKit

class ViewController1: UIViewController {
    var searchController: UISearchController?
    lazy var searchBar = searchController!.searchBar
    let frame = CGRect(origin: .zero, size: CGSize(width: 1, height: 50))
    var searchBarBackgroundImage: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: frame)
        let image = renderer.image { (_) in
            UIColor.white.setFill()
            let rect = UIBezierPath(rect: frame)
            rect.fill()
        }
        return image
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationController()
        configureSearchController()
        configureSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let searchTextField = searchBar.searchTextField
        if let bgView = searchTextField.subviews.first {
//            bgView.dropShadow()
            bgView.setNeedsDisplay()
        }
    }
}

// MARK:- Search bar

extension ViewController1: UISearchBarDelegate {
    func configureNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Denizen"
    }
    
    // configure search controller
    func configureSearchController() {
        let searchResultsController = SearchResultsController()
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController?.searchResultsUpdater = self
        searchController?.isActive = true
        searchController?.hidesNavigationBarDuringPresentation = true
        searchController?.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    func configureSearchBar() {
        // search bar attributes
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.sizeToFit()
        searchBar.tintColor = .black
        searchBar.searchBarStyle = .minimal
        // set the search bar height
        //        searchBar.setSearchFieldBackgroundImage(searchBarBackgroundImage, for: .normal)
        //        searchBar.frame = CGRect(origin: .zero, size: CGSize(width: 1, height: 65))
        
        // search text field attributes
        let searchTextField = searchBar.searchTextField
        //        searchController!.view.frame = CGRect(origin: .zero, size: CGSize(width: 1, height: 65))
        //        searchTextField.frame = CGRect(origin: .zero, size: CGSize(width: 1, height: 65))
    }
    
    func search(shouldShow: Bool) {
        if shouldShow {
            //            searchBar.setSearchFieldBackgroundImage(nil, for: .normal)
        } else {
            //            searchBar.setSearchFieldBackgroundImage(searchBarBackgroundImage, for: .normal)
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        search(shouldShow: true)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
    }
}

extension ViewController1: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else { return }
        if let text = searchController.searchBar.text, !text.isEmpty {
            print("search term", text)
        }
    }
}

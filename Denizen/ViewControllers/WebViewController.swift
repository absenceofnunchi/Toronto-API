//
//  WebViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-16.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView: WKWebView!
    var fetchedData: FetchedData!
    private var shareButton: UIBarButtonItem!
    private var favouriteButton: UIBarButtonItem!
    private let defaults = UserDefaults.standard
    private var unarchivedData = [FetchedData]()
    private var isAlreadyFavourited = false
    var dataSourceDelegate: FavouritesDataSource?
    var urlString: String!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = fetchedData?.title
        
        configureWebView()
        configureNavigationItems()
    }
}

// MARK: - Configure web view

extension WebViewController {
    func configureWebView() {
        guard let id = fetchedData.id else { return }
        urlString = "http://app.toronto.ca/nm/api/individual/notice/" + id + ".do"
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        } else {
            let alertController = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - delegate methods

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationController?.activityStopAnimating()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        navigationController?.activityStartAnimating(activityColor: UIColor.darkGray, backgroundColor: UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.5))
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.navigationController?.activityStopAnimating()
    }
}

// MARK: - Configure navigation item

extension WebViewController {
    func configureNavigationItems() {
        do {
            if let savedFavourites = defaults.object(forKey: Keys.favourites) as? Data {
                let decoded = try JSONDecoder().decode([FetchedData].self, from: savedFavourites)
                unarchivedData.removeAll()
                unarchivedData = decoded
                for data in decoded where data.title == fetchedData.title {
                    isAlreadyFavourited = true
                }
            }
        } catch (let error){
            print(error)
        }
        
        setNavigationItems()
    }
    
    @objc func buttonHandler(_ sender: UIButton) {
        switch sender.tag {
            case 1:
                guard let urlString = self.urlString, let url = URL(string: urlString) else { return }
                let shareSheetVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                present(shareSheetVC, animated: true, completion: nil)
                
                if let pop = shareSheetVC.popoverPresentationController {
                    pop.sourceView = self.view
                    pop.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.height, width: 0, height: 0)
                    pop.permittedArrowDirections = []
                }
            case 2:
                if isAlreadyFavourited {
                    // delete if it already exists
                    unarchivedData.removeAll { $0.title == fetchedData.title }
                } else {
                    // only save if it doesn't already exist
                    unarchivedData.append(fetchedData)
                }
                
                defaults.removeObject(forKey: Keys.favourites)
                
                do {
                    let archived = try JSONEncoder().encode(unarchivedData)
                    defaults.set(archived, forKey: Keys.favourites)
                    defaults.synchronize()
                } catch (let error) {
                    print("archiving error: \(error)")
                }
                
                isAlreadyFavourited.toggle()
                setNavigationItems()
                
                dataSourceDelegate?.configureInitialData()
            default:
                break
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setNavigationItems()
    }
    
    func setNavigationItems() {
        let actionImage = UIImage(systemName: "square.and.arrow.up")?.withTintColor(UIColor.lightGray, renderingMode: .alwaysTemplate)
        let starImage = UIImage(systemName: isAlreadyFavourited ? "star.fill" : "star")
        
        shareButton = UIBarButtonItem(image: actionImage, style: .plain, target: self, action: #selector(buttonHandler(_:)))
        shareButton.tag = 1
        
        favouriteButton = UIBarButtonItem(image: starImage, style: .plain, target: self, action: #selector(buttonHandler(_:)))
        favouriteButton.tag = 2
        if UIDevice.current.orientation.isLandscape {
            shareButton.tintColor = .lightGray
            favouriteButton.tintColor = isAlreadyFavourited ? .yellow : .lightGray
        } else {
            shareButton.tintColor = .white
            favouriteButton.tintColor = isAlreadyFavourited ? .yellow : .white
        }
        
        navigationItem.rightBarButtonItems = [shareButton, favouriteButton]
    }
}

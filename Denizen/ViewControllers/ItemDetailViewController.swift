//
//  ItemDetailViewController.swift
//  Denizen
//
//  Created by J C on 2021-01-25.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    // MARK:- Properties
    
    var fetchedData: FetchedData!
    
    override func loadView() {
        let v = UIView()
        v.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        v.backgroundColor = .systemBackground
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAPI()
    }
}

extension ItemDetailViewController {
    func fetchAPI() {
        let searchCategories = fetchedData.searchCategories
        searchCategories.fetchAPI(url: searchCategories.urlWithQuery, parameters: fetchedData.parameters) { (responseObject, error) in
            print(responseObject)
        }
        
//        WebServiceManager.shared.sendRequest(urlString: searchCategories.urlWithQuery, parameters: fetchedData.parameters) { (responseObject, error) in
//            print(responseObject)
//        }
    }

}

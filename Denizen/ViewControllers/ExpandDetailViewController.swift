//
//  ExpandDetailViewController.swift
//  Denizen
//
//  Created by J C on 2021-01-30.
//

import UIKit

class ExpandDetailViewController: UIViewController {
    // MARK: -  Properties
    
    var itemInfo: ItemInfo!
    var constraints = [NSLayoutConstraint]()

    let label: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .systemBackground
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isEditable = false
        textView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 10
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configure()
    }
}

extension ExpandDetailViewController {
    func configure() {
        view.backgroundColor = UIColor(red: (243/255), green: (243/255), blue: (243/255), alpha: 1)
        
        if let header = itemInfo.header {
            label.text = header
            view.addSubview(label)
            
            textView.text = itemInfo.body
            view.addSubview(textView)
            
            constraints.append(contentsOf: [
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
                textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50)
            ])
        } else {
            textView.text = itemInfo.body
            view.addSubview(textView)
            
            constraints.append(textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50))
        }
        
        constraints.append(contentsOf: [
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
            textView.heightAnchor.constraint(equalToConstant: 200),            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
}

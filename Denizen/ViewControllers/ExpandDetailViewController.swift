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
    var stackView: UIStackView!

    let label: PaddedLabel = {
        let label = PaddedLabel()
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .systemBackground
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
        
        switch itemInfo.itemInfoType {
            case .labelAndTextView:
                label.text = itemInfo.header
                label.layer.cornerRadius = 10
                view.addSubview(label)
                
                textView.text = itemInfo.body
                textView.layer.cornerRadius = 10
                view.addSubview(textView)
                
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                    label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
                    label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
                    
                    textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
                    textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
                    textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
                    textView.heightAnchor.constraint(equalToConstant: 200),
                    textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])
            case .textViewOnly, .noType:
                textView.text = itemInfo.body
                textView.layer.cornerRadius = 10
                textView.dataDetectorTypes = .link
                view.addSubview(textView)
                
                NSLayoutConstraint.activate([
                    textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                    textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
                    textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
                    textView.heightAnchor.constraint(equalToConstant: 200),
                    textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])
            case .dict:
                if let dict = itemInfo.dict {
                    stackView = UIStackView()
                    stackView.axis = .vertical
                    stackView.distribution = .fillEqually
                    stackView.translatesAutoresizingMaskIntoConstraints = false
                    view.addSubview(stackView)

                    for (key, value) in dict {

                        label.text = key
                        
                        if let text = value as? String {
                            textView.text = text
                        } else {
                            textView.text = "null"
                        }
                        
                        let containerView = UIView()
                        containerView.translatesAutoresizingMaskIntoConstraints = false
                        containerView.addSubview(label)
                        containerView.addSubview(textView)
                        stackView.addArrangedSubview(containerView)
                        
                        NSLayoutConstraint.activate([
                            label.topAnchor.constraint(equalTo: containerView.topAnchor),
                            label.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            label.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.3),
                            
                            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                            textView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                            textView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
                            
                            containerView.heightAnchor.constraint(equalToConstant: 100),
                        ])
                    }
                                        
                    NSLayoutConstraint.activate([
                        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
                        stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 10),
                        stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -10),
                        stackView.heightAnchor.constraint(equalToConstant: 500),
                        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    ])
                }
        }
    }

}

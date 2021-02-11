//
//  SearchResultDetailTableViewController.swift
//  Denizen
//
//  Created by J C on 2021-02-08.
//

import UIKit
import Lottie

class DetailViewController: UIViewController {
    let animationView = AnimationView()
    let label = UILabel()
    var searchCategory: SearchCategories!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAnnotation(searchCateogry: searchCategory)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Create annotation

extension DetailViewController {
    func createAnnotation(searchCateogry: SearchCategories?) {
        var labelText: String!
        var animationName: String!
        
        switch searchCateogry {
            case .tags:
                labelText = "Search by related tags.\nEach dataset can have multiple tags."
                animationName = "1"
            case .packages:
                labelText = "Packages are datasets!"
                animationName = "2"
            case .qualityScores:
                labelText = "The Data Quality Score reflects, in the form of a Gold, Silver or Bronze badge."
                animationName = "3"
            case .recentlyChanged:
                labelText = "An activity stream of recently changed datasets."
                animationName = "4"
            case .topics:
                labelText = "Top tags under vocabulary \"Topic.\""
                animationName = "5"
            case .civicIssues:
                labelText = "Datasets filered by civic issues."
                animationName = "6"
            default:
                labelText = "Default Text"
                animationName = "10"
                break
        }
        
        let params: (String, String) = (labelText, animationName)
        
        configureLabel(with: params.0)
        configureAnimation(with: params.1)
        setConstraints()
    }
}

// MARK: -  configure label, animation view, and set constraints

extension  DetailViewController {
    func configureLabel(with text: String) {
        label.text = text
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
    
    func configureAnimation(with name: String) {
        animationView.animation = Animation.named(name)
        animationView.frame = view.bounds
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .white
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // color
        let keypath = AnimationKeypath(keypath: "**.**.**.Color")
        let colorProvider = ColorValueProvider(UIColor(red: 175/255, green: 122/255, blue: 197/255, alpha: 1).lottieColorValue)
        animationView.setValueProvider(colorProvider, keypath: keypath)
        
        animationView.play()
        view.addSubview(animationView)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            // text label
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            // animation
            animationView.widthAnchor.constraint(equalToConstant: 100),
            animationView.heightAnchor.constraint(equalToConstant: 100),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0)
        ])
    }
}


//        let a = animationView.logHierarchyKeypaths()
//        print(a)

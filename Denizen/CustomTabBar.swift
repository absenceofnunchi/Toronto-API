//
//  CustomTabBar.swift
//  Denizen
//
//  Created by J C on 2021-02-17.
//

import UIKit

class CustomTabBar: UIView {
    enum TabItem: Int {
        case main, favourites
        var name: String {
            switch self {
                case .main:
                    return "house"
                case .favourites:
                    return "heart"
            }
        }
        
        var selected: String {
            switch self {
                case .main:
                    return "house.fill"
                case .favourites:
                    return "heart.fill"
            }
        }
        
        var index: Int {
            return rawValue
        }
    }
    
    var tabButton1: UIButton!
    var tabButton2: UIButton!
    var stackView: UIStackView!
    var indicatorLayer = CALayer()
    let color = UIColor(red: 175/255, green: 122/255, blue: 197/255, alpha: 1)
    weak var delegate: CustomTabBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: -0.50, height: 0.50)
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        layer.cornerRadius = 5
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Configure

extension CustomTabBar {
    func configure() {
        // tab buttons
        tabButton1 = createButton(for: .main)
        tabButton1.isSelected = true
        tabButton2 = createButton(for: .favourites)
        
        // stack view
        stackView = UIStackView(arrangedSubviews: [tabButton1, tabButton2])
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        // indicator layer
        stackView.layer.addSublayer(indicatorLayer)
        indicatorLayer.backgroundColor = color.cgColor
        indicatorLayer.frame = CGRect(origin: .zero, size: .init(width: 40, height: 2))
        indicatorLayer.isHidden = true
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func createButton(for tabItem: TabItem) -> UIButton {
        let tabButton = UIButton()
        tabButton.addTarget(self, action: #selector(tabBarButtonHandler(_:)), for: .touchUpInside)
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        let normalImage = UIImage(systemName: tabItem.name)?.withConfiguration(config)
        tabButton.setImage(normalImage, for: .normal)
        
        let selectedImage = UIImage(systemName: tabItem.selected)?.withConfiguration(config)
        tabButton.setImage(selectedImage, for: .selected)
        
        tabButton.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        tabButton.tag = tabItem.index
        tabButton.tintColor = color
        tabButton.translatesAutoresizingMaskIntoConstraints = false
        return tabButton
    }
}

extension CustomTabBar {
    @objc func tabBarButtonHandler(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        indicatorLayer.isHidden = false
        indicatorLayer.position = CGPoint(x: sender.frame.midX, y: sender.frame.minY)

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
        
        for case let button in self.stackView.arrangedSubviews where button is UIButton && button != sender {
            (button as! UIButton).isSelected = false
        }
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: UIView.KeyframeAnimationOptions.calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                sender.transform = .identity
            }
        }, completion: nil)
    
        delegate?.tabBarDidSelect(with: sender.tag)
    }
}




//class CustomTabBar: UIView {
//    enum TabItem {
//        case main, favourites
//    }
//
//    var tabButton1: UIButton!
//    override var frame: CGRect {
//        didSet {
//            self.layoutIfNeeded()
//        }
//    }
//
//    override var bounds: CGRect {
//        didSet {
//            self.layoutIfNeeded()
//        }
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//        setConstraints()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.layer.cornerRadius = self.bounds.size.width / 30
//        self.layer.masksToBounds = true
//        //        self.alpha = 0.9
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func draw(_ rect: CGRect) {
//        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
//        let image = renderer.image { (ctx) in
//            let context = ctx.cgContext
//            context.drawLinearGradient(in: self.bounds, startingWith: UIColor(red: 175/255, green: 122/255, blue: 197/255, alpha: 1).cgColor, finishingWith: UIColor(red: 215/255, green: 189/255, blue: 226/255, alpha: 1).cgColor)
//        }
//        image.draw(in: self.bounds)
//    }
//}
//
//// MARK: - Configure
//
//extension CustomTabBar {
//    func configure() {
//        tabButton1 = UIButton.systemButton(with: UIImage(systemName: "plus")!, target: self, action: #selector(tabBarButtonHandler))
//        tabButton1.tag = 1
//        tabButton1.tintColor = .white
//        tabButton1.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(tabButton1)
//    }
//
//    func setConstraints() {
//        NSLayoutConstraint.activate([
//            tabButton1.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            tabButton1.centerYAnchor.constraint(equalTo: self.centerYAnchor)
//        ])
//    }
//}
//
//extension CustomTabBar {
//    @objc func tabBarButtonHandler(_ sender: UIButton) {
//        switch sender.tag {
//            case 1:
//                print("1")
//            default:
//                break
//        }
//    }
//}

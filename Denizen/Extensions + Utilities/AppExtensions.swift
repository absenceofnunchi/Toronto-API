//
//  AppExtensions.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import UIKit
import SwiftyJSON

// MARK: - UIView

extension UIView {
    func shadowBorder(color: UIColor = .lightGray, opacity: Float = 0.8, offSet: CGSize = CGSize(width: -0.50, height: 0.50), cornerRadius: CGFloat = 15) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offSet
        layer.shadowOpacity = opacity
        layer.shadowRadius = 5
        layer.cornerRadius = cornerRadius
        backgroundColor = .systemBackground
    }
}

extension UIViewController {
    func activityStartAnimating(activityColor: UIColor, backgroundColor: UIColor) {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = 5000
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(activityIndicatorTapped))
        backgroundView.addGestureRecognizer(tap)
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        activityIndicator.tag = 5000
        
        backgroundView.addSubview(activityIndicator)
        self.view.addSubview(backgroundView)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // background view
            backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            backgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            backgroundView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            
            // activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    func activityStopAnimating() {
        DispatchQueue.main.async {
            if let background = self.view.viewWithTag(5000) {
                background.removeFromSuperview()
            }
        }
    }
    
    @objc func activityIndicatorTapped() {
        DispatchQueue.main.async {
            if let background = self.view.viewWithTag(5000) {
                background.removeFromSuperview()
                if let navController = self as? UINavigationController {
                    navController.popViewController(animated: true)
                }
            }
        }
    }
    
    func json2dic(_ j: JSON) -> [String:AnyObject] {
        var post = [String:AnyObject]()
        for (key, object) in j {
            post[key] = object.stringValue as AnyObject
            if object.stringValue == "" {
                post[key] = json2dic(object) as AnyObject
            }
        }
        return post
    }
    
    static var windowInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
}


// MARK: - UITextField

extension UITextField {
    func dropShadow(color: UIColor = .lightGray, opacity: Float = 0.8, offSet: CGSize = CGSize(width: -0.50, height: 0.50), cornerRadius: CGFloat = 15) {
        
        var shadowLayer: CAShapeLayer!
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = UIColor.systemBackground.cgColor
            
            shadowLayer.shadowColor = color.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = offSet
            shadowLayer.shadowOpacity = opacity
            shadowLayer.shadowRadius = 5
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}

// MARK: - Table View
extension UITableViewController {
    
    static let productCellIdentifier = "cellID"
    
    // Used by both MainTableViewController and ResultsTableController to define its table cells.
    func configureCell(_ cell: UITableViewCell, forItemTitle title: String) {
//        let textTitle = NSMutableAttributedString(string: forItemTitle)
//        let textColor = SearchResultsController.suggestedColor(fromIndex: product.color)
//
//        textTitle.addAttribute(NSAttributedString.Key.foregroundColor,
//                               value: textColor,
//                               range: NSRange(location: 0, length: textTitle.length))
//        cell.textLabel?.attributedText = textTitle
        cell.textLabel?.text = title
        
        // Build the price and year as the detail right string.
//        let priceString = product.formattedPrice()
//        let yearString = product.formattedDate()
//        cell.detailTextLabel?.text = "\(priceString!) | \(yearString!)"
//        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = nil
    }
    
}


extension String {
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return String(self[rangeFrom..<rangeTo])
    }
}

// NavBarBackgroundView
extension CGContext {
    func drawLinearGradient(in rect: CGRect, startingWith startColor: CGColor, finishingWith endColor: CGColor) {
        let colorsSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [startColor, endColor] as CFArray
        let locations = [0.0, 1.0] as [CGFloat]
        
        guard let gradient = CGGradient(colorsSpace: colorsSpace, colors: colors, locations: locations) else { return }
        
        let startPoint = CGPoint(x: rect.maxX, y: rect.maxY)
        let endPoint = CGPoint(x: rect.minX, y: rect.minY)
        
        saveGState()
        addRect(rect)
        clip()
        drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions())
        restoreGState()
    }
}

extension UISplitViewController {
    var detailViewController: DetailViewController? {
        let navController = self.viewControllers[1] as? UINavigationController
        return navController?.topViewController as? DetailViewController
    }
}

//extension UISplitViewController {
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        let master = viewControllers.first
//        return master?.preferredStatusBarStyle ?? .default
//    }
//}
//
//extension UINavigationController {
//    open override var preferredStatusBarStyle: UIStatusBarStyle {
//        return topViewController?.preferredStatusBarStyle ?? .default
//    }
//}
//


extension Notification.Name {
    // for detail view controller to be brought foward when collapsed
    static let detailChosen = Notification.Name("detailChosen")
    static let detailDismissed = Notification.Name("detailDismissed")
    static let urlFetched = Notification.Name("urlFetched")
}

//
//  AppExtensions.swift
//  Denizen
//
//  Created by J C on 2021-01-21.
//

import UIKit

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
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
}


extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
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

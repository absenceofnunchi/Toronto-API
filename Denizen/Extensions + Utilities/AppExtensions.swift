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

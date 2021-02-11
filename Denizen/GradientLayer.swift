//
//  GradientLayer.swift
//  Denizen
//
//  Created by J C on 2021-02-10.
//

import UIKit

class GradientLayer: CAGradientLayer {
    var updatedFrame: CGRect!
    var startingColor: CGColor = UIColor(red: 175/255, green: 122/255, blue: 197/255, alpha: 1).cgColor
    var finishingColor: CGColor = UIColor(red: 215/255, green: 189/255, blue: 226/255, alpha: 1).cgColor
    
    init(updatedFrame: CGRect) {
        super.init()
        self.updatedFrame = updatedFrame
        
        configure()
    }
    
    convenience init(updatedFrame: CGRect, startingColor: CGColor, finishingColor: CGColor) {
        self.init(updatedFrame: updatedFrame)
        self.startingColor = startingColor
        self.finishingColor = finishingColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.frame = updatedFrame
        self.colors = [startingColor, finishingColor]
        self.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.endPoint = CGPoint(x: 1.0, y: 0.0)
    }
    
    override func draw(in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        let y: CGFloat = self.bounds.size.height
        let x: CGFloat = self.bounds.size.width
        let path1 = UIBezierPath()
        UIColor.white.setFill()
        
        path1.move(to: CGPoint(x: 0, y: y))
        path1.addLine(to: CGPoint(x: 0, y: y    - 20))
        path1.addCurve(to: CGPoint(x: x, y: y - 80), controlPoint1: CGPoint(x: x * 2 / 3, y: y), controlPoint2: CGPoint(x: x * 5 / 6, y: y - 100 * 6 / 5))
        path1.addLine(to: CGPoint(x: x, y: y))
        path1.close()
        path1.fill(with: .overlay, alpha: 0.6)
        
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 0, y: y))
        path2.addLine(to: CGPoint(x: 0, y: y - 65))
        path2.addCurve(to: CGPoint(x: x, y: y - 20), controlPoint1: CGPoint(x: x * 3 / 6, y: y - 100 * 5 / 5), controlPoint2: CGPoint(x: x * 2 / 3, y: y))
        path2.addLine(to: CGPoint(x: x, y: y))
        path2.close()
        path2.fill(with: .overlay, alpha: 0.6)
        
        let path3 = UIBezierPath()
        path3.move(to: CGPoint(x: 0, y: y))
        path3.addLine(to: CGPoint(x: 0, y: y - 40))
        path3.addCurve(to: CGPoint(x: x, y: y - 60), controlPoint1: CGPoint(x: x * 5 / 6, y: y - 100 * 2 / 5), controlPoint2: CGPoint(x: x * 2 / 3, y: y - 10))
        path3.addLine(to: CGPoint(x: x, y: y))
        path3.close()
        path3.fill(with: .overlay, alpha: 0.5)
        
        UIGraphicsPopContext()
    }
}

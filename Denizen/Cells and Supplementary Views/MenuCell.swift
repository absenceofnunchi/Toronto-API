//
//  MenuCollectionCell.swift
//  Denizen
//
//  Created by J C on 2021-01-22.
//

/*
 Abstract:
 Menu cell for the initial page
 */

import UIKit

class MenuCell: UICollectionViewCell {
    // MARK:- Properties
    
    let label = UILabel()
    static let reuseIdentifier = Cell.menuCell
    
    /// The `UUID` for the data this cell is presenting.
    var representedIdentifier: UUID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
}

// MARK: - Configure

extension MenuCell {
    func configure() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        contentView.addSubview(label)
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
        ])
    }
}

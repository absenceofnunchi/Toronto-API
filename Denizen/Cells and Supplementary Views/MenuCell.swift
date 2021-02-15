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
    
    let titleLabel = UILabel()
    let dateLabel = UILabel()
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
        // title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontForContentSizeCategory = true
//        titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .gray
        contentView.addSubview(titleLabel)
        
        // date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textAlignment = .center
        dateLabel.textColor = .lightGray
        contentView.addSubview(dateLabel)
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        let inset = CGFloat(5)
        NSLayoutConstraint.activate([
            // title label
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/2),
            
            // date label
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            dateLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/2),
        ])
    }
}

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
    let subTitleLabel = UILabel()
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
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .gray
        contentView.addSubview(titleLabel)
        
        // subtitle
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.adjustsFontForContentSizeCategory = true
        subTitleLabel.textAlignment = .center
        subTitleLabel.textColor = .lightGray
        subTitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        contentView.addSubview(subTitleLabel)

        // date label
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textAlignment = .center
        dateLabel.textColor = .lightGray
        contentView.addSubview(dateLabel)
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            // title label
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
//            titleLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1/2),
            
            // subtitle label
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            subTitleLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -inset),
            
            // date label
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
        ])
    }
}

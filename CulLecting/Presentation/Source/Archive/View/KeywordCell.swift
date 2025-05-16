//
//  KeywordCell.swift
//  CulLecting
//
//  Created by 김승희 on 5/6/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


final class KeywordCell: UICollectionViewCell {
    static let identifier = "KeywordCell"

    private let label = UILabel().then {
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey90
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.lineBreakMode = .byClipping
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor.primaryTint10
        contentView.layer.borderColor = UIColor.primary50.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 19
        contentView.clipsToBounds = true

        contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with keyword: String) {
        label.text = keyword
    }
}

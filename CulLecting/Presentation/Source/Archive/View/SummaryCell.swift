//
//  SummaryCell.swift
//  CulLecting
//
//  Created by 김승희 on 5/6/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


final class SummaryCell: UICollectionViewCell {
    static let identifier = "SummaryCell"

    private let titleLabel = UILabel().then {
        $0.font = .fontPretendard(style: .caption12M)
        $0.textColor = .grey70
        $0.textAlignment = .center
    }

    private let valueLabel = UILabel().then {
        $0.font = .fontPretendard(style: .bold32B)
        $0.textColor = .grey90
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor.grey10
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

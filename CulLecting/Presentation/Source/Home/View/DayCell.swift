//
//  DayCell.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


import UIKit

import FlexLayout
import PinLayout
import Then

final class DayCell: UICollectionViewCell {
    static let identifier = "DayCell"

    private let dayLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.textAlignment = .center
        $0.textColor = .grey90 // ✅ 색상 명시
    }

    private let dateLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textAlignment = .center
        $0.textColor = .grey90 // ✅ 색상 명시
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dayLabel)
        contentView.addSubview(dateLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        dayLabel.sizeToFit()
        dateLabel.sizeToFit()

        dayLabel.pin.top(5).hCenter()
        dateLabel.pin.below(of: dayLabel).marginTop(5).hCenter()
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.primaryTint20 : .clear
            contentView.layer.cornerRadius = 8
        }
    }

    func configure(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        dayLabel.text = formatter.string(from: date)

        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)

        setNeedsLayout()
    }
}

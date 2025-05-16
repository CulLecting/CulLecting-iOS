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
        $0.font = .fontPretendard(style: .body13M)
        $0.textAlignment = .center
        $0.textColor = .grey50
    }

    private let dateLabel = UILabel().then {
        $0.font = .fontPretendard(style: .title16SB)
        $0.textAlignment = .center
        $0.textColor = .grey90
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

        dayLabel.pin.top(10).hCenter()
        dateLabel.pin.below(of: dayLabel).marginTop(5).hCenter()
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.grey90 : .clear
            contentView.layer.cornerRadius = 10
            dayLabel.textColor = isSelected ? .white : .grey50
            dateLabel.textColor = isSelected ? .white : .grey90
        }
    }

    func configure(date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        formatter.dateFormat = "E"
        dayLabel.text = formatter.string(from: date)

        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)

        setNeedsLayout()
    }
}

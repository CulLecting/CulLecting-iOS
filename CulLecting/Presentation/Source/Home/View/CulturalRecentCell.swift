//
//  CulturalRecentCell.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import Then
import PinLayout
import Kingfisher


/// 최근 컬렉션뷰에 사용
final class CulturalRecentCell: UICollectionViewCell {
    
    static let identifier = "CulturalRecentCell"
    
    // MARK: UI Components
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    
    private let placeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    private let periodLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .gray
    }
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    private func setupUI() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(placeLabel)
        contentView.addSubview(periodLabel)
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        thumbnailImageView.pin
            .top(8)
            .left(0)
            .width(80)
            .height(80)
        
        let textStartX = thumbnailImageView.frame.maxX + 12
        let textWidth = contentView.bounds.width - textStartX - 16
        
        titleLabel.pin
            .top(8)
            .left(textStartX)
            .width(textWidth)
            .sizeToFit(.width)
        
        placeLabel.pin
            .below(of: titleLabel, aligned: .left)
            .marginTop(4)
            .width(textWidth)
            .sizeToFit(.width)
        
        periodLabel.pin
            .below(of: placeLabel, aligned: .left)
            .marginTop(2)
            .width(textWidth)
            .sizeToFit(.width)
    }
    
    // MARK: Configure
    func configure(with content: CulturalContentEntity) {
        if let url = URL(string: content.imageURL) {
            thumbnailImageView.kf.setImage(with: url)
        }
        titleLabel.text = content.title
        placeLabel.text = content.place
        if let start = content.startDate, let end = content.endDate {
            periodLabel.text = "\(start) ~ \(end)"
        } else {
            periodLabel.text = ""
        }
    }
}

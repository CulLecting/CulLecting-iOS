//
//  CulturalContentCell.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import FlexLayout
import Kingfisher
import PinLayout
import RxCocoa
import RxSwift
import Then


///날짜별 컬렉션뷰, 추천 컬렉션뷰에 사용
final class CulturalContentHorizontalCell: UICollectionViewCell {
    static let identifier = "CulturalContentHorizontalCell"

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .lightGray
    }

    private let titleLabel = UILabel().then {
        $0.font = .fontPretendard(style: .title16SB)
        $0.textColor = .grey90
        $0.numberOfLines = 1
    }

    private let placeLabel = UILabel().then {
        $0.font = .fontPretendard(style: .body13M)
        $0.textColor = .grey70
        $0.numberOfLines = 1
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(placeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.width * 1.4)
        titleLabel.frame = CGRect(x: 0, y: imageView.frame.maxY + 8, width: contentView.bounds.width, height: 20)
        placeLabel.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 4, width: contentView.bounds.width, height: 18)
    }

    func configure(with content: CulturalContentEntity) {
        if let url = URL(string: content.imageURL) {
            imageView.kf.setImage(with: url)
        }
        titleLabel.text = content.title
        placeLabel.text = content.place
    }
}

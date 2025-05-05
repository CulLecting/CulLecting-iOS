//
//  TicketCell.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import Kingfisher


final class SearchedImageCell: UICollectionViewCell {
    
    static let identifier = "SearchedImageCell"
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.pin.all()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with culturalImg: CulturalImageEntity) {
        if let url = URL(string: culturalImg.imageURL) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
        }
    }
}

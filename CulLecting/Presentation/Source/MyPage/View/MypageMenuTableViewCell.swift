//
//  MypageMenuTableViewCell.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


class MypageMenuTableViewCell: UITableViewCell {
    static let mypageMenuTableViewCellIdentifier = "MypageMenuTableViewCell"
    
    private let menuView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    private let menuIcon = UIImageView().then {
        $0.image = UIImage.topLogo
        $0.tintColor = .grey90
        $0.contentMode = .scaleAspectFit
    }
    private let menuLabel = UILabel().then {
        $0.text = "히히"
        $0.font = .fontPretendard(style: .title16M)
        $0.textColor = .grey90
    }
    private let chevronIcon = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .grey90
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        menuView.pin.all(contentView.pin.safeArea)
        menuView.flex.layout()
    }
    
    //MARK: UI
    private func setUI() {
        contentView.backgroundColor = .clear
        contentView.addSubview(menuView)
        
        menuView.flex
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .padding(10, 10)
            .height(56)
            .define {
                $0.addItem(menuIcon)
                    .width(24)
                    .height(24)
                    .marginRight(20)
                $0.addItem(menuLabel)
                    .grow(1)
                    .marginRight(20)
                $0.addItem(chevronIcon)
                    .width(20)
                    .height(20)
                    .marginRight(20)
            }
    }
    
    public func configure(menuItem: MypageMenu) {
        menuIcon.image = menuItem.icon
        menuLabel.text = menuItem.title
    }
}

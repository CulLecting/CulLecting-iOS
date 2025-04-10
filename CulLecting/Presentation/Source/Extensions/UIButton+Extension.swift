//
//  UIButton+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit
import Then

enum ButtonStyle {
    case darkButtonActive
    case darkButtonDisabled
}

extension UIButton {
    static func makeButton(style: ButtonStyle, title: String, cornerRadius: CGFloat) -> UIButton {
        //MARK: 높이, 모서리 둥글기 따로 설정 필요함
        
        var backgroundColor: UIColor
        var titleColor: UIColor
        var titleFont: UIFont
        
        switch style {
        case .darkButtonActive:
            backgroundColor = UIColor.grey90
            titleColor = .white
            titleFont = .fontPretendard(style: .title16SB)
            
        case .darkButtonDisabled:
            backgroundColor = UIColor.grey90
            titleColor = .grey70
            titleFont = .fontPretendard(style: .title16SB)
        }
        
        let button = UIButton().then {
            $0.backgroundColor = backgroundColor
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = titleFont
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
        }
        button.setTitle(title, for: .normal)
        
        return button
    }
}


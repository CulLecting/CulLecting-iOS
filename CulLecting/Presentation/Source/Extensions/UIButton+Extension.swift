//
//  UIButton+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit

enum ButtonStyle {
    case darkButtonActive
    case dartButtonDisabled
}

extension UIButton {
    static func makeButton(style: ButtonStyle, title: String) -> UIButton {
        //MARK: 높이, 모서리 둥글기 따로 설정 필요함
        
        var backgroundColor: UIColor
        var titleColor: UIColor
        var titleFont: UIFont
        
        switch style {
        case .darkButtonActive:
            backgroundColor = UIColor.grey90
            titleColor = .white
            titleFont = .fontPretendard(style: .title16SB)
            
        case .dartButtonDisabled:
            backgroundColor = UIColor.grey90
            titleColor = .grey70
            titleFont = .fontPretendard(style: .title16SB)
        }
        
        let button: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = backgroundColor
            button.setTitleColor(titleColor, for: .normal)
            button.titleLabel?.font = titleFont
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            return button
        }()
        button.setTitle(title, for: .normal)
        
        return button
    }
}


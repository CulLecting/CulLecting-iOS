//
//  UIButton+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit
import Then

enum BarButtonStyle {
    case darkButtonActive
    case darkButtonDisabled
}

enum TextButtonStyle {
    case underlineTrue
    case underlineFalse
}

enum OnboardingButtonStyle {
    case plain
    case chosen
}

extension UIButton {
    
    /// 기본 버튼 만들기
    static func makeButton(style: BarButtonStyle, title: String, cornerRadius: CGFloat) -> UIButton {
        let button = UIButton().then {
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
        }
        button.setTitle(title, for: .normal)
        button.applyBarButtonStyle(style)
        return button
    }
        
    /// 기존 버튼 인스턴스의 스타일을 업데이트하는  메서드
    func applyBarButtonStyle(_ style: BarButtonStyle) {
        switch style {
        case .darkButtonActive:
            self.backgroundColor = UIColor.grey90
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = UIFont.fontPretendard(style: .title16SB)
        case .darkButtonDisabled:
            self.backgroundColor = UIColor.grey90
            self.setTitleColor(.grey70, for: .normal)
            self.titleLabel?.font = UIFont.fontPretendard(style: .title16SB)
        }
    }
    
    /// 글자만 있는 버튼 만들기
    static func makeTextButton(title: String,
                                   titleColor: UIColor,
                                   font: UIFont,
                                   backgroundColor: UIColor = .clear,
                               underline: TextButtonStyle) -> UIButton {
        let button = UIButton(type: .system)
        
        switch underline {
        case .underlineTrue:
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: titleColor,
                .font: font,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            button.setAttributedTitle(attributedTitle, for: .normal)
            
        case .underlineFalse:
            button.setTitle(title, for: .normal)
            button.setTitleColor(titleColor, for: .normal)
            button.titleLabel?.font = font
        }
        return button
    }
    
    /// 온보딩 버튼 만들기
    static func makeOnboardingButton(title: String, style: OnboardingButtonStyle) -> UIButton {
        let button = UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.applyOnboardingStyle(style)
        }
        return button
    }
    
    /// 온보딩 스타일 적용
    func applyOnboardingStyle(_ style: OnboardingButtonStyle) {
        self.titleLabel?.font = UIFont.fontPretendard(style: .body14M)
        self.layer.cornerRadius = 22
        self.clipsToBounds = true
        
        switch style {
        case .plain:
            self.backgroundColor = .grey10
            self.setTitleColor(.grey70, for: .normal)
            self.layer.borderWidth = 0
        case .chosen:
            self.backgroundColor = .primaryTint10
            self.setTitleColor(.primary50, for: .normal)
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.primary50.cgColor
        }
        self.layoutIfNeeded()
    }
    
//    static func mypageButton(title: String, icon: UIImage) -> UIButton {
//        let attributedsString = NSMutableAttributedString(string: title)
//        let imageAttachment = NSTextAttachment()
//        imageAttachment.image = icon
//        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 24, height: 24)
//        attributedsString.append(NSAttributedString(attachment: imageAttachment))
//        attributedsString.append(NSAttributedString(string: title))
//        
//
//        let button = UIButton().then {
//            //위의 attributestring을 text로 등록
//            $0.titleLabel?.font = UIFont.fontPretendard(style: .title16M)
//            $0.titleLabel?.textColor = .grey90
//            // 오른쪽 이미지를 setimage로 등록 (chevron.right, 색상은 grey90)
//            $0.layer.cornerRadius = 20
//        }
//        return button
//    }
}


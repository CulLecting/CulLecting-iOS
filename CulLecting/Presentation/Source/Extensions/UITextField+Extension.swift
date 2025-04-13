//
//  UITextField+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit

enum TextFieldStyle {
    case defaultStyle
    case wrongInputStyle
    case disabledStyle
}

extension UITextField {
    static func makeTextField(style: TextFieldStyle, placeholderText: String?) -> UITextField {
        //MARK: 입력시 글자색이 바뀌는 등의 처리는 Delegate를 통해 처리해야 함
        //MARK: rightView 등도 따로 설정
        let placeHolderColor: UIColor
        let backgroundColor: UIColor
        let borderColor: CGColor
        
        switch style {
        case .defaultStyle:
            placeHolderColor = .grey50
            backgroundColor = .grey20
            borderColor = UIColor.grey20.cgColor
        case .wrongInputStyle:
            placeHolderColor = .grey50
            backgroundColor = .grey20
            borderColor = UIColor.primaryShade60.cgColor
        case .disabledStyle:
            placeHolderColor = .grey50
            backgroundColor = .grey30
            borderColor = UIColor.grey30.cgColor
        }
        
        let textField: UITextField = {
            let textField = UITextField()
            if let text = placeholderText {
                let attributedText = NSAttributedString(string: text, attributes: [.foregroundColor: placeHolderColor, .font: UIFont.fontPretendard(style: .body14R)])
                textField.attributedPlaceholder = attributedText
            }
            textField.backgroundColor = backgroundColor
            textField.layer.borderColor = borderColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 10
            return textField
        }()
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))
        leftPaddingView.backgroundColor = .clear
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        
        return textField
    }
}

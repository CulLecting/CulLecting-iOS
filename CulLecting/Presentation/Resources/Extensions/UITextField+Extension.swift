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
        // 입력시 글자색이 바뀌는 등의 처리는 Delegate를 통해 처리해야 함
        // rightView 등도 따로 설정
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
    
    /// 눈모양 비밀번호 토글버튼 추가
    func enablePasswordToggle() {
            let toggleButton = UIButton(type: .system)
        toggleButton.setImage(UIImage.pwEyeSlash, for: .normal)
            toggleButton.tintColor = .grey60
            toggleButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

            toggleButton.addAction(UIAction(handler: { [weak self] _ in
                guard let self = self else { return }
                self.isSecureTextEntry.toggle()
                let imageName = self.isSecureTextEntry ? "pwEyeSlash" : "pwEye"
                toggleButton.setImage(UIImage(named: imageName), for: .normal)
            }), for: .touchUpInside)

            let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
            container.addSubview(toggleButton)
            toggleButton.pin.right(10).vCenter()

            self.rightView = container
            self.rightViewMode = .always
        }
}

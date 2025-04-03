//
//  UILabel+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit

enum LineSpacingStyle {
    case large
    case medium
}

extension UILabel {
    static func setLineSpacing(style: LineSpacingStyle, text: String) -> NSAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        
        switch style {
        case .large:
            paragraphStyle.minimumLineHeight = 24
            paragraphStyle.maximumLineHeight = 24
        case .medium:
            paragraphStyle.minimumLineHeight = 18
            paragraphStyle.maximumLineHeight = 18
            
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

//
//  UIFont+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit

enum FontStyle {
    case title18SB
    case title18R
    case title16SB
    case title16M
    case body14M
    case body14R
    case body13SB
    case body13M
    case body13R
    case caption12M
    case caption12R
    case caption11SB
    case caption11R
}

extension UIFont {
    static func fontPretendard(style: FontStyle) -> UIFont {
        let fontName = "PretendardVariable"
        let fontsize: CGFloat
        let fontweight: UIFont.Weight
        
        switch style {
        case .title18SB:
            fontsize = 18
            fontweight = .semibold
        case .title18R:
            fontsize = 18
            fontweight = .regular
        case .title16SB:
            fontsize = 16
            fontweight = .semibold
        case .title16M:
            fontsize = 16
            fontweight = .medium
        case .body14M:
            fontsize = 14
            fontweight = .medium
        case .body14R:
            fontsize = 14
            fontweight = .regular
        case .body13SB:
            fontsize = 13
            fontweight = .semibold
        case .body13M:
            fontsize = 13
            fontweight = .medium
        case .body13R:
            fontsize = 13
            fontweight = .regular
        case .caption12M:
            fontsize = 12
            fontweight = .medium
        case .caption12R:
            fontsize = 12
            fontweight = .regular
        case .caption11R:
            fontsize = 11
            fontweight = .regular
        case .caption11SB:
            fontsize = 11
            fontweight = .semibold
        }
        return UIFont(name: fontName, size: fontsize) ?? UIFont.systemFont(ofSize: fontsize, weight: fontweight)
    }
}

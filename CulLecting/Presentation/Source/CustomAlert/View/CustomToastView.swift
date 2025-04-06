//
//  CustomToastView.swift
//  CulLecting
//
//  Created by 김승희 on 4/3/25.
//

import UIKit
import FlexLayout
import Then


enum toastIconStyle {
    case normal
    case caution
}

final class CustomToastView: UIView {
    //MARK: UI Components
    
    private let iconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let toastLabel = UILabel().then {
        $0.font = UIFont.fontPretendard(style: .body14M)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    //MARK: init
    public init(message: String, iconStyle: toastIconStyle) {
        super.init(frame: .zero)
        setInit(message: message, iconStyle: iconStyle)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.flex.layout()
    }
    
    private func setInit(message: String, iconStyle: toastIconStyle) {
        toastLabel.text = message
        
        switch iconStyle {
        case .caution:
            iconView.image = UIImage.tickCircleGreyBorder
        case .normal:
            iconView.image = UIImage.tickCircleBlackFill
        }
    }
    
    private func setUI() {
        
        self.backgroundColor = UIColor.grey70.withAlphaComponent(0.8)
        
        self.flex
            .direction(.row)
            .alignItems(.center)
            .paddingVertical(10)
            .paddingHorizontal(10)
            .define { flex in
                flex.addItem(iconView)
                    .size(CGSize(width: 24, height: 24))
                
                flex.addItem(toastLabel)
                    .marginLeft(10)
                    .maxWidth(200)
                
            }
    }
}

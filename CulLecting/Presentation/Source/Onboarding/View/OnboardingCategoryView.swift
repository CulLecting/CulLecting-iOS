//
//  OnboardingCategoryView.swift
//  CulLecting
//
//  Created by 김승희 on 4/12/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


public class OnboardingCategoryView: UIView {

    private lazy var buttons: [UIButton] = {
        return Category.allCases.map {
            UIButton.makeOnboardingButton(title: $0.rawValue, style: .plain)
        }
    }()
    
    private lazy var gridStackView: UIStackView = {
        let verticalStack = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 15
            $0.alignment = .fill
            $0.distribution = .fillEqually
        }
        
        let rows = Int(ceil(Double(buttons.count) / 2.0))
        for i in 0..<rows {
            let horizontalStack = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 15
                $0.alignment = .fill
                $0.distribution = .fillEqually
            }
            for j in 0..<2 {
                let index = i * 2 + j
                if index < buttons.count {
                    let button = buttons[index]
                    horizontalStack.addArrangedSubview(button)
                } else {
                    horizontalStack.addArrangedSubview(UIView())
                }
            }
            verticalStack.addArrangedSubview(horizontalStack)
        }
        return verticalStack
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gridStackView.pin.all()
        gridStackView.flex.layout()
        gridStackView.pin.maxHeight(280)
    }
    
    private func setupUI() {
        addSubview(gridStackView)
    }
    
    func getAllButtons() -> [UIButton] {
        return buttons
    }
}

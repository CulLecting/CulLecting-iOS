//
//  OnboardingFinishViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/10/25.
//

import UIKit

import FlexLayout
import PinLayout
import Then

final class OnboardingFinishViewController: UIViewController {
    
    var onFinish: (()->Void)?
    
    private let iconView = UIImageView().then {
        $0.image = UIImage.cullectingIconWhite
    }
    
    private let firstLabel = UILabel().then {
        $0.text = "가입이 완료되었어요!"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .white
    }
    
    private let secondLabel = UILabel().then {
        $0.text = "지금 바로 컬렉팅 해보세요!"
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .white
    }
    
    private lazy var startButton = UIButton.makeButton(style: .darkButtonActive, title: "시작하기", cornerRadius: 28).then {
        $0.addTarget(self, action: #selector(onTapStartButton), for: .touchUpInside)
    }
    
    @objc private func onTapStartButton() {
        print("onTapStartButton 클릭됨")
        onFinish?()
    }
    
    //MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.pin.all(view.pin.safeArea)
        container.flex.layout()
    }
    
    //MARK: UI
    private func setBackgroundImage() {
        let backgroundImg = UIImage.onboardingFinishBackground
        let backgrountImgView = UIImageView(image: backgroundImg)
        backgrountImgView.contentMode = .scaleAspectFit
        view.insertSubview(backgrountImgView, at: 0)
        backgrountImgView.pin.all()
    }
    
    private let container = UIView()
    private let iconContainer = UIView()
    
    private func setUI() {
        view.addSubview(container)
        
        container.flex
            .direction(.column)
            .marginHorizontal(20)
            .define {
                $0.addItem(iconContainer)
                    .grow(1)
                $0.addItem(startButton)
                    .marginBottom(50)
                    .height(56)
            }
        
        iconContainer.flex
            .direction(.column)
            .justifyContent(.center)
            .alignItems(.center)
            .define {
                $0.addItem(iconView)
                $0.addItem(firstLabel)
                    .marginTop(40)
                $0.addItem(secondLabel)
                    .marginTop(10)
            }
    }
}

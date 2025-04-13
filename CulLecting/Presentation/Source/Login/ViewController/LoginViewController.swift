//
//  ViewController.swift
//  CulLecting
//
//  Created by 김승희 on 3/25/25.
//

import UIKit

import FlexLayout
import PinLayout
import Then

class LoginViewController: UIViewController {
    
    private let logo = UIImageView().then {
        $0.image = UIImage.topLogo
    }
    
    private let loginLabel = UILabel().then {
        $0.text = "로그인"
        $0.textColor = .grey90
        $0.font = .fontPretendard(style: .title18SB)
    }
    
    private let idTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "이메일 입력")
    
    private lazy var pwTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 입력").then {
        $0.textContentType = .password
        $0.rightView = hidePwButton
        $0.rightViewMode = .always
        $0.isSecureTextEntry = true
    }
    
    private lazy var hidePwButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.pwEyeSlash, for: .normal)
        button.tintColor = .grey60
        button.addAction(UIAction(handler: { [weak self, weak button] _ in
            guard let self = self, let button = button else { return }
            self.pwTextField.isSecureTextEntry.toggle()
            let toggleImg = self.pwTextField.isSecureTextEntry ? "pwEyeSlash" : "pwEye"
            button.setImage(UIImage(named: toggleImg), for: .normal)
        }), for: .primaryActionTriggered)
        // button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        return button
    }()
    
    private let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 44))

    private let resetPwButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        var attributedContainer = AttributeContainer()
        attributedContainer.font = UIFont.fontPretendard(style: .body14M)
        config.attributedTitle = AttributedString("비밀번호 재설정", attributes: attributedContainer)
        config.baseForegroundColor = .grey80
        config.imagePlacement = .trailing
        let imgconfig = UIImage.SymbolConfiguration(pointSize: 10)
        config.image = UIImage(systemName: "chevron.right", withConfiguration: imgconfig)
        config.imagePadding = 10
        $0.configuration = config
    }
    
    private let loginButton = UIButton.makeButton(style: .darkButtonDisabled, title: "로그인", cornerRadius: 28)
    
    private let joinLabel = UILabel().then {
        $0.text = "아직 회원이 아니신가요?"
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey80
    }
    
    private lazy var joinButton = UIButton.makeTextButton(title: "회원가입", titleColor: .primary50, font: .fontPretendard(style: .body14M), underline: .underlineTrue).then {
        $0.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            let joinVC = JoinViewController()
            self.navigationController?.pushViewController(joinVC, animated: true)
        }), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        print("LoginViewController DidLoaded")
        view.backgroundColor = .white
        super.viewDidLoad()
        
        setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginContainerView.pin.all(view.pin.safeArea)        
        loginContainerView.flex.layout()
    }
    
    init() {
        print("init LoginViewController")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit LoginViewController")
    }
    
    //MARK: UI
    let loginContainerView = UIView()
    let textFieldSubView = UIView()
    let joinContainer = UIView()
    
    private func setUI() {
        view.addSubview(loginContainerView)
        
        loginContainerView
            .flex
            .direction(.column)
            .marginHorizontal(20)
            .define {
                $0.addItem(logo)
                    .marginTop(100)
                    .marginBottom(40)
                    .alignSelf(.center)
                
                $0.addItem(loginLabel)
                    .marginBottom(50)
                    .alignSelf(.center)
                
                textFieldSubView
                    .flex
                    .direction(.column)
                    .define {
                        $0.addItem(idTextField)
                            .height(56)
                            .marginBottom(10)
                        $0.addItem(pwTextField)
                            .height(56)
                    }
                
                $0.addItem(textFieldSubView)
                    .marginBottom(20)
                
                $0.addItem(resetPwButton)
                    .marginBottom(20)
                    .alignSelf(.end)
                
                $0.addItem(loginButton)
                    .marginBottom(20)
                    .height(56)
                
                $0.addItem().grow(1)
                
                joinContainer
                    .flex
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(joinLabel)
                        $0.addItem(joinButton)
                            .marginLeft(10)
                    }
                $0.addItem(joinContainer)
                    .alignSelf(.center)
                    .marginBottom(20)
            }
    }
}

//
//  JoinViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/8/25.
//


import UIKit
import FlexLayout
import PinLayout
import Then

class JoinViewController: UIViewController {
    
    private let emailTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "이메일 입력")
    private let emailAuthButton = UIButton.makeButton(style: .darkButtonActive, title: "인증", cornerRadius: 10)
    private let verificationTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "인증번호 입력")
    private let verificationDoneButton = UIButton.makeButton(style: .darkButtonActive, title: "인증 완료", cornerRadius: 10)
    private let passwordTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 입력")
    private let confirmPasswordTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 확인")
    private let nicknameTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "닉네임 입력")
    
    private let termsToggleButton = UIButton().then {
        $0.setImage(UIImage.tickCirclePrimeFill , for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    }
    
    private let termsLabel = UILabel().then {
        $0.text = "가입 약관에 모두 동의합니다."
        $0.font = .fontPretendard(style: .body14R)
        $0.textColor = .grey80
    }
    
    private let termsConfirmButton = UIButton.makeTextButton(title: "확인하기", titleColor: .primary50, font: .fontPretendard(style: .body14M), underline: .underlineTrue)
    
    private let nextButton = UIButton.makeButton(style: .darkButtonDisabled, title: "다음", cornerRadius: 28)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        joinContainerView.pin.all(view.pin.safeArea)
        joinContainerView.flex.layout()
    }
    
    // MARK: - Navigation Setup
    private func setupNavigationBar() {
        navigationItem.title = "가입하기"
        let backItem = UIBarButtonItem(
            image: UIImage.arrowLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backItem
        self.navigationController?.navigationBar.tintColor = .grey90
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI Setup
    
    private let joinContainerView = UIView()
    private let textInputView = UIView()
    private let emailInputView = UIView()
    private let pwInputView = UIView()
    private let policyView = UIView()
    
    private func setupUI() {
        view.addSubview(joinContainerView)
        
        joinContainerView
            .flex
            .direction(.column)
            .marginTop(50)
            .marginHorizontal(20)
            .define {
                $0.addItem(textInputView)
                    .marginBottom(24)
                    .grow(1)
                $0.addItem(nextButton)
                    .height(56)
                    .marginBottom(24)
            }
        
        textInputView
            .flex
            .direction(.column)
            .define {
                emailInputView
                    .flex
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                        $0.addItem(emailTextField)
                            .height(56)
                            .grow(1)
                        $0.addItem(emailAuthButton)
                            .height(56)
                            .width(100)
                            .marginLeft(16)
                    }
                
                $0.addItem(emailInputView)
                    .marginBottom(16)
                
                $0.addItem(pwInputView)
                    .marginBottom(16)
                
                pwInputView
                    .flex
                    .direction(.row)
                    .alignItems(.center)
                    .define {
                    $0.addItem(verificationTextField)
                        .height(56)
                        .grow(1)
                    $0.addItem(verificationDoneButton)
                        .height(56)
                        .width(100)
                        .marginLeft(16)
                }
                 
                $0.addItem(passwordTextField)
                    .height(56)
                    .marginBottom(16)
                
                $0.addItem(confirmPasswordTextField)
                    .height(56)
                    .marginBottom(16)
                
                $0.addItem(nicknameTextField)
                    .height(56)
                    .marginBottom(20)
                
                $0.addItem(policyView)
            }
        
        policyView
            .flex
            .direction(.row)
            .alignItems(.center)
            .define {
            $0.addItem(termsToggleButton)
            $0.addItem(termsLabel)
                .marginLeft(8)
                .grow(1)
            $0.addItem(termsConfirmButton)
                .marginRight(8)
        }
    }
}

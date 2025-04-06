//
//  ViewController.swift
//  CulLecting
//
//  Created by 김승희 on 3/25/25.
//

import UIKit

import FlexLayout
import PinLayout

class LoginViewController: UIViewController {
    
    private let logo: UILabel = {
        let logo = UILabel()
        logo.text = "CulLecting"
        logo.textColor = .black
        logo.font = .systemFont(ofSize: 36, weight: .bold)
        return logo
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "로그인"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    private let idTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.placeholder = "아이디"
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 18)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let pwTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.placeholder = "비밀번호"
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 18)
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let changePwButton: UILabel = {
        let button = UILabel()
        button.text = "비밀번호를 잊으셨나요?"
        button.backgroundColor = .clear
        button.font = .systemFont(ofSize: 14, weight: .light)
        button.textColor = .lightGray
        return button
    }()
    
    private let hidePwButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "loginEye"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("로그인", for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    private let joinButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = .darkGray
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    override func viewDidLoad() {
        print("LoginViewController DidLoaded")
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginContainerView.pin.all(view.pin.safeArea)
        
        let desiredWidth = loginContainerView.bounds.width * 0.8
        idTextField.flex.width(desiredWidth)
        pwTextField.flex.width(desiredWidth)
        loginButton.flex.width(desiredWidth)
        joinButton.flex.width(desiredWidth)
        
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
    let buttonSubView = UIView()
    
    private func setUI() {
        view.addSubview(loginContainerView)
        
        loginContainerView.flex.direction(.column).define { flex in
            
            flex.addItem(logo)
                .marginTop(200)
                .marginBottom(50)
                .alignSelf(.center)
            
//            flex.addItem(loginLabel)
//                .marginBottom(20)
//                .alignSelf(.center)
            
            textFieldSubView.flex.direction(.column).define { flex in
                flex.addItem(idTextField)
                    .height(44)
                    .alignSelf(.center)
                    .marginBottom(10)
                flex.addItem(pwTextField)
                    .height(44)
                    .alignSelf(.center)
            }
            
            flex.addItem(textFieldSubView)
                .marginBottom(40)
                .alignSelf(.center)
            
            buttonSubView.flex.direction(.column).define { flex in
                flex.addItem(loginButton)
                    .height(48)
                    .alignSelf(.center)
                    .marginBottom(10)
                flex.addItem(joinButton)
                    .height(48)
                    .alignSelf(.center)
            }
            
            flex.addItem(buttonSubView)
                .marginBottom(20)
            
            flex.addItem(changePwButton)
                .alignSelf(.center)
            
        }
    }


}


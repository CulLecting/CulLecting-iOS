//
//  ViewController.swift
//  CulLecting
//
//  Created by 김승희 on 3/25/25.
//

import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then

class LoginViewController: UIViewController {
    weak var coordinator: LoginCoordinator?
    
    private let viewModel: LoginViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: UI Components
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
        $0.isSecureTextEntry = true
        $0.enablePasswordToggle()
    }

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
    
    private lazy var joinButton = UIButton.makeTextButton(
        title: "회원가입",
        titleColor: .primary50,
        font: .fontPretendard(style: .body14M),
        underline: .underlineTrue
    ).then {
        $0.addAction(UIAction(handler: { [weak self] _ in
            print("회원가입 버튼 눌림")
            self?.coordinator?.showJoinView()
        }), for: .touchUpInside)
    }
    
    private lazy var guestButton = UIButton.makeTextButton(
        title: "둘러보기",
        titleColor: .primary50,
        font: .fontPretendard(style: .body14M),
        underline: .underlineFalse).then {
            $0.addAction(UIAction(handler: { [weak self] _ in
                self?.coordinator?.continueAsGuest()
            }), for: .touchUpInside)
        }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        print("LoginViewController DidLoaded")
        view.backgroundColor = .white
        super.viewDidLoad()
        setUI()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginContainerView.pin.all(view.pin.safeArea)
        loginContainerView.flex.layout()
        
        guestButton.pin
            .top(view.pin.safeArea.top).marginTop(0)
            .right(view.pin.safeArea.right).marginRight(16)
            .sizeToFit()
    }
    
    init(viewModel: LoginViewModel, coordinator: LoginCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit LoginViewController")
    }
    
    //MARK: ViewModel Bind
    private func bindViewModel() {
        let input = LoginViewModel.Input(
            email: idTextField.rx.text.orEmpty.asObservable(),
            password: pwTextField.rx.text.orEmpty.asObservable(),
            loginTap: loginButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.loginResult
            .drive(onNext: { result in
                switch result {
                case .success(let token):
                    print("로그인 성공: \(token)")
                    self.coordinator?.didLoginSuccess()
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                    self.showAlert(title: "로그인 실패", message: "로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.")
                }
            })
            .disposed(by: disposeBag)
        
        output.isFormValid
            .drive(onNext: { [weak self] isValid in
                let style: BarButtonStyle = isValid ? .darkButtonActive : .darkButtonDisabled
                self?.loginButton.applyBarButtonStyle(style)
                self?.loginButton.isEnabled = isValid
            })
            .disposed(by: disposeBag)
        
        resetPwButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.coordinator?.showResetPassword()
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: UI
    let loginContainerView = UIView()
    let textFieldSubView = UIView()
    let joinContainer = UIView()
    
    private func setUI() {
        view.addSubview(loginContainerView)
        view.addSubview(guestButton)
        
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

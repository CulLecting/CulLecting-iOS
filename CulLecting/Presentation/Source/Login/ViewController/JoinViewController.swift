//
//  JoinViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/8/25.
//


import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then

class JoinViewController: UIViewController {
    
    //MARK: Properties
    private weak var coordinator: LoginCoordinator?
    private let viewModel: JoinViewModel
    private let disposeBag = DisposeBag()
    
    private var isTermsAccepted = BehaviorRelay<Bool>(value: false)
    
    //MARK: UI Components
    private let emailTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "이메일 입력")
    private let emailAuthButton = UIButton.makeButton(style: .darkButtonActive, title: "인증 요청", cornerRadius: 10)
    private let verificationTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "인증번호 입력")
    private let verificationDoneButton = UIButton.makeButton(style: .darkButtonDisabled, title: "인증", cornerRadius: 10)
    private let passwordTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 입력")
    private let confirmPasswordTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 확인")
    private let nicknameTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "닉네임 입력")
    
    private let passwordWarningLabel = UILabel().then {
        $0.text = "비밀번호가 일치하지 않아요!"
        $0.textColor = .red
        $0.font = .fontPretendard(style: .body13R)
        $0.isHidden = true
    }
    
    private let termsToggleButton = UIButton().then {
        $0.setImage(UIImage.tickCircleGreyBorder , for: .normal)
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        $0.tintColor = .grey70
    }
    
    private let termsLabel = UILabel().then {
        $0.text = "가입 약관에 모두 동의합니다."
        $0.font = .fontPretendard(style: .body14R)
        $0.textColor = .grey80
    }
    
    private let termsConfirmButton = UIButton.makeTextButton(title: "확인하기",
                                                             titleColor: .primary50,
                                                             font: .fontPretendard(style: .body14M),
                                                             underline: .underlineTrue)
    
    private let nextButton = UIButton.makeButton(style: .darkButtonActive, title: "다음", cornerRadius: 28)

    // MARK: - Life Cycle
    init(viewModel: JoinViewModel, coordinator: LoginCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupActions()
        bindViewModel()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        joinContainerView.pin.all(view.pin.safeArea)
        joinContainerView.flex.layout()
    }
    
    //MARK: Bind
    private func bindViewModel() {
        let input = JoinViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asObservable(),
            sendCodeTap: emailAuthButton.rx.tap.asObservable(),
            verificationCode: verificationTextField.rx.text.orEmpty.asObservable(),
            verifyCodeTap: verificationDoneButton.rx.tap.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            confirmPassword: confirmPasswordTextField.rx.text.orEmpty.asObservable(),
            nickname: nicknameTextField.rx.text.orEmpty.asObservable(),
            termsAccepted: isTermsAccepted.asObservable(),
            nextTap: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isSendCodeEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.emailAuthButton.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
        
        output.isVerifyEnabled
            .drive(verificationDoneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.isNextEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.passwordMatchWarning
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showWarning in
                self?.passwordWarningLabel.isHidden = !showWarning
                self?.confirmPasswordTextField.layer.borderColor = showWarning ? UIColor.red.cgColor : UIColor.clear.cgColor
                self?.confirmPasswordTextField.layer.borderWidth = showWarning ? 1 : 0
            })
            .disposed(by: disposeBag)
        
        output.emailSendResult
            .emit(onNext: { [weak self] success in
                self?.showAlert(
                    title: success ? "성공" : "실패",
                    message: success ? "인증번호가 발송되었습니다." : "이메일 형식을 확인해주세요."
                )
            })
            .disposed(by: disposeBag)
        
        // 인증 성공 후 버튼 상태 변경
        output.emailVerified
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] verified in
                guard let self else { return }
                if verified {
                    self.verificationDoneButton.applyBarButtonStyle(.darkButtonDisabled)
                    self.verificationDoneButton.setTitle("인증 완료", for: .normal)
                    self.verificationDoneButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        
        // 회원가입 요청 처리
        output.joinResult
            .drive(onNext: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.showAlert(title: "회원가입 성공", message: "가입을 축하드립니다! 컬렉팅에게 여러분의 취향을 알려주세요.") {
                        self.coordinator?.showOnboardingFlow()
                    }
                case .failure(let error):
                    self.showAlert(title: "회원가입 실패", message: error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }

    
    // MARK: Methods
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
    
    private func setupActions() {
        let toggleAction = UIAction { [weak self] _ in
            guard let self else { return }
            let newValue = !self.isTermsAccepted.value
            self.isTermsAccepted.accept(newValue)
            let newImage = newValue ? UIImage.tickCirclePrimeFill : UIImage.tickCircleGreyBorder
            self.termsToggleButton.setImage(newImage, for: .normal)
        }
        termsToggleButton.addAction(toggleAction, for: .touchUpInside)
    }
    
    // MARK: UI
    
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
                    .marginBottom(4)
                
                $0.addItem(passwordWarningLabel)
                    .marginBottom(12)
                
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

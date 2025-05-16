//
//  ResetPasswordViewController.swift
//  CulLecting
//
//  Created by 김승희 on 5/9/25.
//


import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then


class ResetPasswordViewController: UIViewController {
    
    // MARK: Properties
    private weak var coordinator: LoginCoordinator?
    private let viewModel: ResetPasswordViewModel
    private let disposeBag = DisposeBag()
    private var isTermsAccepted = BehaviorRelay<Bool>(value: false)
    
    // MARK: UI Components
    private let emailTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "이메일 입력")
    private let emailAuthButton = UIButton.makeButton(style: .darkButtonActive, title: "인증 요청", cornerRadius: 10)
    private let verificationTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "인증번호 입력")
    private let verificationDoneButton = UIButton.makeButton(style: .darkButtonDisabled, title: "인증", cornerRadius: 10)
    private let passwordTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 입력").then {
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.enablePasswordToggle()
    }
    private let confirmPasswordTextField = UITextField.makeTextField(style: .defaultStyle, placeholderText: "비밀번호 확인").then {
        $0.textContentType = .password
        $0.isSecureTextEntry = true
        $0.enablePasswordToggle()
    }
    private let passwordWarningLabel = UILabel().then {
        $0.text = "비밀번호가 일치하지 않아요!"
        $0.textColor = .red
        $0.font = .fontPretendard(style: .body13R)
        $0.isHidden = true
    }
    private let confirmButton = UIButton.makeButton(style: .darkButtonActive, title: "확인", cornerRadius: 28)
    
    private let containerView = UIView()
    private let inputStackView = UIView()
    private let emailInputView = UIView()
    private let verificationInputView = UIView()
    
    // MARK: init
    init(viewModel: ResetPasswordViewModel, coordinator: LoginCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.pin.all(view.pin.safeArea)
        containerView.flex.layout()
    }
    
    // MARK: Setup
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "비밀번호 재설정"
        
        let backItem = UIBarButtonItem(
            image: UIImage.arrowLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backItem
        navigationController?.navigationBar.tintColor = .grey90
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.flex
            .direction(.column)
            .marginHorizontal(20)
            .marginTop(50)
            .define {
                $0.addItem(inputStackView)
                    .grow(1)
                    .marginBottom(24)
                $0.addItem(confirmButton)
                    .height(56)
                    .marginBottom(24)
            }
        
        inputStackView.flex
            .direction(.column)
            .define {
                emailInputView.flex.direction(.row).alignItems(.center).define {
                    $0.addItem(emailTextField).height(56).grow(1)
                    $0.addItem(emailAuthButton).height(56).width(100).marginLeft(16)
                }
                $0.addItem(emailInputView).marginBottom(16)
                
                verificationInputView.flex.direction(.row).alignItems(.center).define {
                    $0.addItem(verificationTextField).height(56).grow(1)
                    $0.addItem(verificationDoneButton).height(56).width(100).marginLeft(16)
                }
                $0.addItem(verificationInputView).marginBottom(16)
                
                $0.addItem(passwordTextField).height(56).marginBottom(16)
                $0.addItem(confirmPasswordTextField).height(56).marginBottom(4)
                $0.addItem(passwordWarningLabel).marginBottom(12)
            }
    }
}

// binding
extension ResetPasswordViewController {
    private func bindViewModel() {
        let input = ResetPasswordViewModel.Input(
            email: emailTextField.rx.text.orEmpty.asObservable(),
            sendCodeTap: emailAuthButton.rx.tap.asObservable(),
            verificationCode: verificationTextField.rx.text.orEmpty.asObservable(),
            verifyCodeTap: verificationDoneButton.rx.tap.asObservable(),
            password: passwordTextField.rx.text.orEmpty.asObservable(),
            confirmPassword: confirmPasswordTextField.rx.text.orEmpty.asObservable(),
            resetTap: confirmButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isVerifyEnabled
            .drive(verificationDoneButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.isNextEnabled
            .drive(confirmButton.rx.isEnabled)
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
                    message: success ? "인증번호가 발송되었습니다." : "인증 메일 발송에 실패했습니다.\ncamelcasemail@gmail.com으로 문의를 남겨주세요."
                )
                if success {
                    self?.verificationDoneButton.applyBarButtonStyle(.darkButtonActive)
                    self?.verificationDoneButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)

        output.emailVerified
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] verified in
                guard let self else { return }
                if verified {
                    self.verificationDoneButton.applyBarButtonStyle(.darkButtonDisabled)
                    self.verificationDoneButton.setTitle("인증 완료", for: .normal)
                    self.verificationDoneButton.isEnabled = false
                    self.verificationTextField.isEnabled = false
                    self.verificationTextField.backgroundColor = .grey30
                }
            })
            .disposed(by: disposeBag)

        output.resetResult
            .drive(onNext: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.showAlert(title: "비밀번호 변경 성공", message: "비밀번호가 성공적으로 변경되었습니다.") {
                        self.coordinator?.showLoginFlow()
                    }
                case .failure(let error):
                    self.showAlert(title: "비밀번호 변경 실패", message: "\(error.localizedDescription)\ncamelcasemail@gmail.com으로 문의를 남겨주세요.")
                }
            })
            .disposed(by: disposeBag)

        viewModel.showVerificationFailedAlert = { [weak self] in
            self?.showAlert(title: "오류", message: "인증번호를 확인해주세요.")
        }
    }
}

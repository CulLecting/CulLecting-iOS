//
//  OnboardingViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then


class OnboardingViewController: UIViewController {
    
    var viewModel = OnboardingViewModel()
    var onFinishTransition: (() -> Void)?
    private let disposeBag = DisposeBag()
    
    //MARK: UI Components
    
    private let blackLogo = UIImageView().then {
        $0.image = UIImage.cullectingIconBlack.resize(newSize: CGSize(width: 38, height: 32))
        $0.contentMode = .scaleAspectFit
    }
    
    private let skipButton = UIButton.makeTextButton(title: "건너뛰기", titleColor: .grey70, font: .fontPretendard(style: .body14M), underline: .underlineFalse)
    
    private lazy var backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: nil, action: nil).then {
        $0.tintColor = .grey90
    }
    
    private let progressBar = UIProgressView().then {
        $0.progressViewStyle = .bar
        $0.progressTintColor = .primary50
        $0.trackTintColor = .grey30
        $0.progress = 0.5
    }
    
    private let firstLabel = UILabel().then {
        $0.text = "주로 어디에서 문화 콘텐츠를 즐기세요?"
        $0.textColor = .grey90
        $0.font = .fontPretendard(style: .title18SB)
    }
    
   private let secondLabel = UILabel().then {
        $0.text = "최대 3개까지 선택할 수 있어요."
        $0.textColor = .grey50
        $0.font = .fontPretendard(style: .title18SB)
    }
    
    private let stackButtonContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let categoryView = OnboardingCategoryView()
    private let locationView = OnboardingLocationView()
    
    private let nextButton = UIButton.makeButton(style: .darkButtonDisabled, title: "다음", cornerRadius: 28)
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        print("OnboardingViewController DidLoaded")
        super.viewDidLoad()
        setupNavigationBar()
        setUI()
        bindViewModel()
        bind()
    }
    
    init() {
        print("OnboardingViewController init됨")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("OnboardingViewController deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootViewContainer.pin.all(view.pin.safeArea)
        rootViewContainer.flex.layout()
        setStackButtonView()
    }
    
    
    //MARK: RX + bind
    private let nextTrigger = PublishSubject<Void>()
    private let backTrigger = PublishSubject<Void>()
    private let categoryButtonTapRelay = PublishSubject<String>()
    private let locationButtonTapRelay = PublishSubject<String>()
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        let input = OnboardingViewModel.Input(nextTrigger: nextTrigger.asObservable(),
                                              backTrigger: backTrigger.asObservable(),
                                              tapCategory: categoryButtonTapRelay.asObservable(),
                                              tapLocation: locationButtonTapRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.currentStep
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] step in
                guard let self = self else { return }
                let containerFrame = self.stackButtonContainerView.bounds
                switch step {
                    
                case .location:
                    UIView.animate(withDuration: 0.3) {
                        self.locationView.frame = containerFrame
                        self.categoryView.frame = containerFrame.offsetBy(dx: containerFrame.width + 40, dy: 0)
                    }
                    self.navigationItem.leftBarButtonItem = nil
                    
                case .category:
                    UIView.animate(withDuration: 0.3) {
                        self.locationView.frame = containerFrame.offsetBy(dx: -(containerFrame.width + 40), dy: 0)
                        self.categoryView.frame = containerFrame
                    }
                    self.navigationItem.leftBarButtonItem = self.backButton
                }
            })
            .disposed(by: disposeBag)
        
        output.selectedLocations
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selected in
                print("selectedLocations 호출")
                self?.updateLocationButtonStyles(selected: selected)
            })
            .disposed(by: disposeBag)
        
        output.selectedCategories
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selected in
                self?.updateCategoryButtonStyles(selected: selected)
            })
            .disposed(by: disposeBag)
        
        output.labelText
            .observe(on: MainScheduler.instance)
            .bind(to: firstLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.enableNext
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                if isEnabled {
                    self.nextButton.applyBarButtonStyle(.darkButtonActive)
                } else {
                    self.nextButton.applyBarButtonStyle(.darkButtonDisabled)
                }
            })
            .disposed(by: disposeBag)
        
        
        output.progress
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] progress in
                UIView.animate(withDuration: 0.3) {
                    self?.progressBar.setProgress(progress, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        output.finish
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] finished in
                if finished {
                    print("온보딩 완료 - OnboardingFinishedViewController로 전환")
                    guard let self = self else { return }
                    self.onFinishTransition?()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        locationView.getAllButtons().forEach { button in
            button.rx.tap
                .map { button.currentTitle ?? "" }
                .bind(to: locationButtonTapRelay)
                .disposed(by: disposeBag)
        }
        
        categoryView.getAllButtons().forEach { button in
            button.rx.tap
                .map { button.currentTitle ?? "" }
                .bind(to: categoryButtonTapRelay)
                .disposed(by: disposeBag)
        }

        nextButton.rx.tap
            .bind(to: nextTrigger)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind(to: backTrigger)
            .disposed(by: disposeBag)
    }
    
    //MARK: 기타 메서드
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.titleView = blackLogo
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: skipButton)
    }
    
    private func updateLocationButtonStyles(selected: Set<String>) {
        locationView.getAllButtons().forEach { button in
            let isSelected = selected.contains(button.currentTitle ?? "")
            let style: OnboardingButtonStyle = isSelected ? .chosen : .plain
            button.applyOnboardingStyle(style)
        }
    }
    
    private func updateCategoryButtonStyles(selected: Set<String>) {
        categoryView.getAllButtons().forEach { button in
            let isSelected = selected.contains(button.currentTitle ?? "")
            let style: OnboardingButtonStyle = isSelected ? .chosen : .plain
            button.applyOnboardingStyle(style)
        }
    }
    
    //MARK: UI Setup
    
    private let rootViewContainer = UIView()
    //private let navigationContainerView = UIView()
    private let labelContainerView = UIView()
    
    private func setStackButtonView() {
        let containerFrame = stackButtonContainerView.bounds
        locationView.frame = containerFrame
        categoryView.frame = containerFrame.offsetBy(dx: containerFrame.width, dy: 0)
    }
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(rootViewContainer)
        
        [locationView, categoryView].forEach { stackButtonContainerView.addSubview($0) }
        
        rootViewContainer.flex
            .direction(.column)
            .marginHorizontal(20)
            .define {
                //$0.addItem(navigationContainerView)
                $0.addItem(progressBar)
                    .marginTop(20)
                $0.addItem(labelContainerView)
                    .marginTop(30)
                $0.addItem(stackButtonContainerView)
                    .marginHorizontal(0)
                    .marginTop(20)
                    .marginBottom(20)
                    .grow(1)
                $0.addItem(nextButton)
                    .height(56)
                    .marginBottom(50)
            }
        
//        navigationContainerView.flex
//            .direction(.row)
//            .alignItems(.baseline)
//            .alignContent(.center)
//            .marginHorizontal(0)
//            .define {
//                $0.addItem(backButton)
//                    .marginLeft(20)
//                    .grow(1)
//                $0.addItem(blackLogo)
//                    .grow(1)
//                $0.addItem(skipButton)
//                    .marginRight(20)
//            }
        
        labelContainerView.flex
            .direction(.column)
            .define {
                $0.addItem(firstLabel)
                    .marginBottom(5)
                $0.addItem(secondLabel)
            }
    }
    
}


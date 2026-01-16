//
//  OnboardingFinishViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/10/25.
//

import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then

final class OnboardingFinishViewController: UIViewController {

    private let viewModel: OnboardingViewModel
    private weak var coordinator: OnboardingCoordinator?
    private let disposeBag = DisposeBag()
    private let startTrigger = PublishRelay<Void>()

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

    private let startButton = UIButton.makeButton(style: .darkButtonActive, title: "시작하기", cornerRadius: 28)

    //MARK: LifeCycle
    init(viewModel: OnboardingViewModel, coordinator: OnboardingCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        setUI()
        bindViewModel()
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

// MARK: - Binding
private extension OnboardingFinishViewController {

    func bindViewModel() {
        startButton.rx.tap
            .do(onNext: { print("onTapStartButton 클릭됨") })
            .bind(to: startTrigger)
            .disposed(by: disposeBag)

        let input = OnboardingViewModel.Input(
            nextTrigger: .empty(),
            backTrigger: .empty(),
            skipTrigger: .empty(),
            tapCategory: .empty(),
            tapLocation: .empty(),
            startTrigger: startTrigger.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.navigationEvent
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .completeOnboarding:
                    self?.coordinator?.didFinishOnboarding()
                case .showFinishScreen:
                    break  // Already on finish screen
                }
            })
            .disposed(by: disposeBag)
    }
}

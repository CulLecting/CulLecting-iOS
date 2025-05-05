//
//  HomeViewController.swift
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

final class HomeViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: HomeViewModel
    private let coordinator: HomeCoordinator
    private let disposeBag = DisposeBag()
    
    // MARK: UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let ticketLabel = UILabel().then {
        $0.text = "최근의 문화 순간들"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey90
    }
    private let emptyTicketView = UIView().then {
        let imageView = UIImageView(image: UIImage.mainArchiveDefault)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tag = 100
        $0.addSubview(imageView)
    }
    private let myTicketView = TicketListView()
    private let datePickerHeaderView = DatePickerHeaderView()
    private let culturalContentHorizontalView = CulturalContentHorizontalView()
    private let recommendSectionView = CulturalRecommendContentSectionView()
    private let recentSectionView = CulturalRecentContentSectionView()
    
    private let floatingButton = UIButton().then {
        $0.setTitle("+ 기록하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .fontPretendard(style: .title16SB)
        $0.backgroundColor = .grey90
        $0.layer.cornerRadius = 27
    }
    
    // MARK: Init
    init(viewModel: HomeViewModel, coordinator: HomeCoordinator) {
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
        setupUI()
        setNavigationBar()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
}

// MARK: - Setup
private extension HomeViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(floatingButton)
        scrollView.addSubview(contentView)
        
        [ ticketLabel,
          emptyTicketView,
          myTicketView,
          datePickerHeaderView,
          culturalContentHorizontalView,
          recommendSectionView,
          recentSectionView
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func layout() {
        scrollView.pin.all(view.pin.safeArea)
        contentView.pin.top().horizontally().width(of: scrollView)
        floatingButton.pin
            .bottom(view.pin.safeArea.bottom + 16)
            .right(20)
            .width(114)
            .height(56)

        [myTicketView, emptyTicketView, datePickerHeaderView,
         culturalContentHorizontalView, recommendSectionView, recentSectionView]
            .forEach { $0.setNeedsLayout(); $0.layoutIfNeeded() }

        contentView.flex
            .direction(.column)
            .paddingTop(20)
            .define { flex in
                flex.addItem(ticketLabel)
                    .alignSelf(.start)
                    .marginLeft(20)

                if myTicketView.isHidden {
                    flex.addItem(emptyTicketView)
                        .marginTop(16)
                        .marginHorizontal(20)
                        .height(142)
                } else {
                    flex.addItem(myTicketView)
                        .marginTop(16)
                        .marginLeft(20)
                        .height(myTicketView.frame.height)
                }

                flex.addItem(datePickerHeaderView)
                    .marginTop(24)
                    .marginHorizontal(20)
                    .height(datePickerHeaderView.frame.height)

                flex.addItem(culturalContentHorizontalView)
                    .marginTop(0)
                    .marginLeft(10)
                    .height(culturalContentHorizontalView.frame.height)

                flex.addItem(recommendSectionView)
                    .marginTop(30)
                    .marginLeft(10)
                    .height(recommendSectionView.frame.height)

                flex.addItem(recentSectionView)
                    .marginTop(30)
                    .marginLeft(10)
                    .height(recentSectionView.frame.height)
            }

        contentView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentView.frame.size
    }
    
    func setNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.primeLogo, style: .plain, target: nil, action: nil).then {
            $0.tintColor = UIColor.primary50
        }
    }
}

//MARK: Bind
private extension HomeViewController {
    
    func bindViewModel() {
        let input = HomeViewModel.Input(
            viewWillAppearTrigger: rx.methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
                .map { _ in }
                .asObservable(),
            selectedDate: datePickerHeaderView.selectedDate.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.myTickets
            .drive(onNext: { [weak self] (tickets: [Ticket]) in
                guard let self else { return }
                let isEmpty = tickets.isEmpty
                self.emptyTicketView.isHidden = !isEmpty
                self.myTicketView.isHidden = isEmpty
                if !isEmpty {
                    self.myTicketView.configure(with: tickets)
                }
                self.view.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        output.recommendCulturals
            .drive(onNext: { [weak self] (contents: [CulturalContentEntity]) in
                self?.recommendSectionView.collectionView.reloadData()
                self?.recommendSectionView.configure(with: contents)
            })
            .disposed(by: disposeBag)
        
        output.latestCulturals
            .drive(onNext: { [weak self] (categoryMap: [String: [CulturalContentEntity]]) in
                self?.recentSectionView.configure(with: categoryMap)
            })
            .disposed(by: disposeBag)
        
        output.todayCulturals
            .drive(onNext: { [weak self] contents in
                self?.culturalContentHorizontalView.configure(with: contents)
            })
            .disposed(by: disposeBag)
        
        floatingButton.rx.tap
            .bind { [weak self] in
                print("버튼 눌림")
                self?.coordinator.moveToArchiveTab()
            }
            .disposed(by: disposeBag)

    }
}

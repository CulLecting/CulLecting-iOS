//
//  FilterModalViewController.swift
//  CulLecting
//
//  Created by SeungHwanMacBook on 5/8/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

class FilterModalViewController: UIViewController {
    
    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator
    private let disposeBag = DisposeBag()

    //MARK: init
    init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSheetPresentation()
    }
    
    private let scrollView = UIScrollView()
    
    private let categoryView = CategoryCollectionView()
    private let regionView = RegionCollectionView()
    private let costView = CostCollectionView()
    private let ageView = AgeCollectionView()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 0.5
        button.backgroundColor = .grey5
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("적용하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .grey90
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [resetButton, applyButton])
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetFilters), for: .touchUpInside)
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()

    private func setupUI() {
        view.addSubview(scrollView)
        view.backgroundColor = .white
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.snp.edges)
        }
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        containerView.addSubview(categoryView)
        containerView.addSubview(regionView)
        containerView.addSubview(costView)
        containerView.addSubview(ageView)
        containerView.addSubview(buttonStackView)
        
        categoryView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        regionView.snp.makeConstraints {
            $0.top.equalTo(categoryView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(350)
        }
        
        costView.snp.makeConstraints {
            $0.top.equalTo(regionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        ageView.snp.makeConstraints {
            $0.top.equalTo(costView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(ageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    
    
    private func configureSheetPresentation() {
        if let sheet = sheetPresentationController {
            let twoThirdsHeight = UISheetPresentationController.Detent.custom { context in
                return context.maximumDetentValue * (2 / 3) // 화면의 3분의 2 높이
            }
            sheet.detents = [twoThirdsHeight] // ✅ 3분의 2 높이로 설정
            sheet.prefersGrabberVisible = true   // ✅ 상단 핸들 표시
            sheet.preferredCornerRadius = 16     // ✅ 모서리 둥글게
        }
    }
    
    @objc private func resetFilters() {
        print("필터 초기화")
        categoryView.resetItem()
        regionView.resetItem()
        costView.resetItem()
        ageView.resetItem()
    }
    
    @objc private func applyFilters() {
        print("필터 적용하기")
        print("카테고리: \(categoryView.getItem() ?? "없음")")
        print("지역: \(regionView.getItem() ?? "없음")")
        print("비용: \(costView.getItem() ?? "없음")")
        print("연령: \(ageView.getItem() ?? "없음")")
        let isFree: Bool? = ageView.getItem() == "무료" ? true : ageView.getItem() == "유료" ? false : nil
        let filter = FilterRequestDTO.init(codeName: categoryView.getItem(), guName: regionView.getItem(), themeCode: costView.getItem(), isFree: isFree)
        viewModel.findDataFromFilter(filter: filter)
        dismiss(animated: true)
    }
    
    
}




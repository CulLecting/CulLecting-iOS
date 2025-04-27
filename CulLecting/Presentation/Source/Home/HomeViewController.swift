//
//  HomeViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


final class HomeViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let logoImageView = UIImageView(image: UIImage.primeLogo).then {
        $0.contentMode = .scaleAspectFit
    }

    private let searchButton = UIButton().then {
        $0.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        $0.tintColor = .grey90
    }

    private let sectionTitleLabel = UILabel().then {
        $0.text = "최근의 문화 순간들"
        $0.font = .boldSystemFont(ofSize: 18)
    }

    private let placeholderCard = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 12
    }

    private let emptyRecordButton = UIButton().then {
        $0.setTitle("＋ 첫 문화 경험을 기록해보세요", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .systemGray6
    }

    private let calendarSectionLabel = UILabel().then {
        $0.text = "오늘의 문화 일정"
        $0.font = .boldSystemFont(ofSize: 18)
    }

    private let categoryFilterLabel = UILabel().then {
        $0.text = "최근 열린 문화 콘텐츠"
        $0.font = .boldSystemFont(ofSize: 18)
    }

    private let recommendationLabel = UILabel().then {
        $0.text = "취향에 맞춘 추천 콘텐츠"
        $0.font = .boldSystemFont(ofSize: 18)
    }
    
    private let floatingButton = UIButton().then {
        $0.setTitle("＋ 기록하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .fontPretendard(style: .title18SB)
        $0.backgroundColor = .grey90
        $0.layer.cornerRadius = 27
        $0.layer.borderWidth = 0
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.15
        $0.layer.shadowOffset = CGSize(width: 0, height: 3)
        $0.layer.shadowRadius = 5
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        setAction()
    }

    private func layout() {
        view.addSubview(scrollView)
        view.addSubview(floatingButton)
        scrollView.addSubview(contentView)
        
        scrollView.pin.all()
        contentView.pin.top().horizontally().width(of: scrollView)
        
        contentView.flex.paddingHorizontal(20).paddingTop(20).define { flex in
            flex.addItem().direction(.row).justifyContent(.spaceBetween).alignItems(.center).define {
                $0.addItem(logoImageView).size(32)
                $0.addItem(searchButton).size(24)
            }
            flex.addItem(sectionTitleLabel).marginTop(20)
            //flex.addItem(placeholderCard).marginTop(10).height(200)
            flex.addItem(emptyRecordButton).marginTop(16).height(200)
            flex.addItem(calendarSectionLabel).marginTop(30)
            flex.addItem(UIView().then { $0.backgroundColor = .grey30;
                $0.layer.cornerRadius = 8 }).marginTop(8).height(300)
            flex.addItem(categoryFilterLabel).marginTop(30)
            flex.addItem(UIView().then { $0.backgroundColor = .grey50;
                $0.layer.cornerRadius = 8 }).marginTop(8).height(300)
            flex.addItem(recommendationLabel).marginTop(30)
            flex.addItem(UIView().then { $0.backgroundColor = .grey70;
                $0.layer.cornerRadius = 8 }).marginTop(8).height(200)
            
            floatingButton.pin
                .bottom(view.pin.safeArea.bottom + 20)
                .right(20)
                .width(54)
                .height(54)
        }
        
        contentView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentView.frame.size
    }
    
    private func setAction() {
        // 플로팅 버튼 클릭 시
        floatingButton.addAction(UIAction { [weak self] _ in
            self?.didTapFloatingButton()
        }, for: .touchUpInside)

        // 돋보기 버튼 클릭 시
        searchButton.addAction(UIAction { [weak self] _ in
            self?.didTapSearchButton()
        }, for: .touchUpInside)
    }

    @objc private func didTapFloatingButton() {
        // 간단한 더미로 연결
        let useCase = ArchivingUseCase(repository: ArchivingRepository())
        let viewModel = AddTicketViewModel(useCase: useCase)
        let addVC = AddTicketViewController(viewModel: viewModel)
        navigationController?.pushViewController(addVC, animated: true)
    }

    @objc private func didTapSearchButton() {
        // 탭바의 2번 인덱스로 이동
        self.tabBarController?.selectedIndex = 2
    }

}

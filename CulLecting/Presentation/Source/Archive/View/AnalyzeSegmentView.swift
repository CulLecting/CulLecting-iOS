//
//  AnalyzeSegmentView.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


final class AnalyzeSegmentView: UIView {

    private let scrollView = UIScrollView()
    private let dataContainerView = UIView()
    private let emptyContainerView = UIView().then {
        $0.backgroundColor = .white
    }

    private let cardImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }

    let keywordView = KeywordView()
    let summaryView = SummaryView()

    private let emptyLabelUp = UILabel().then {
        $0.text = "취향 카드가 없어요."
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey70
        $0.textAlignment = .center
    }

    private let emptyLabelDown = UILabel().then {
        $0.text = "기록 카드가 3개 이상일 때 취향 분석이 시작돼요!"
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey60
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with entity: PreferenceCardEntity, ticketCount: Int) {
        let hasEnoughData = ticketCount >= 3

        dataContainerView.isHidden  = !hasEnoughData
        emptyContainerView.isHidden =  hasEnoughData

        if hasEnoughData {
            keywordView.configure(keywords: entity.keywords)
            summaryView.configure(count: entity.culturalCount,
                                  category: entity.manyCategory.rawValue)
            setCategoryImage(category: entity.manyCategory)
        }
        setNeedsLayout()
    }


    func setCategoryImage(category: PreferenceCategory) {
        cardImageView.image = UIImage(named: category.imageName)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        scrollView.pin.all()

        if !dataContainerView.isHidden {
            dataContainerView.pin
                .top()
                .horizontally()
                .sizeToFit(.width)
            dataContainerView.flex.layout(mode: .adjustHeight)
        }

        if !emptyContainerView.isHidden {
            emptyContainerView.pin
                .top()
                .horizontally()
                .height(scrollView.bounds.height)
            emptyContainerView.flex.layout()
        }

        let contentH = !dataContainerView.isHidden
            ? dataContainerView.frame.maxY
            : scrollView.bounds.height
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width,
            height: contentH
        )
    }

    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(dataContainerView)
        scrollView.addSubview(emptyContainerView)

        let cardWidth = UIScreen.main.bounds.width * 0.9
        let cardHeight = cardWidth * (372.0 / 327.0)

        dataContainerView.flex.direction(.column).padding(20).define {
            $0.addItem(cardImageView)
                .width(cardWidth)
                .height(cardHeight)
                .alignSelf(.center)
            $0.addItem(keywordView)
                .marginTop(36)
                .marginHorizontal(0)
                .height(80)
            $0.addItem(summaryView).marginTop(36).height(200)
        }

        emptyContainerView.flex.direction(.column)
            .alignItems(.center)
            .justifyContent(.center)
            .paddingHorizontal(20).define {
                $0.addItem(emptyLabelUp)
                $0.addItem(emptyLabelDown).marginTop(8)
            }
    }
}

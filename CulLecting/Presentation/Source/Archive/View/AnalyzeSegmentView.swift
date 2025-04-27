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
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let cardImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let keywordLabel = UILabel().then {
        $0.text = "나의 문화 키워드"
        $0.font = .fontPretendard(style: .title16SB)
        $0.textColor = .black
    }
    
    let keywordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }
    
    private let summaryLabel = UILabel().then {
        $0.text = "나의 문화 소비 요약"
        $0.font = .fontPretendard(style: .title16SB)
        $0.textColor = .black
    }
    
    let summaryTableView = UITableView().then {
        $0.isScrollEnabled = false
        $0.separatorStyle = .none
        $0.backgroundColor = .clear
    }
    
    private let emptyLabelUp = UILabel().then {
        $0.text = "취향 카드가 없어요."
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey70
    }
    
    private let emptyLabelDown = UILabel().then {
        $0.text = "기록 카드가 3개 이상일 때 취향 분석이 시작돼요!"
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey60
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUI()
    }
    
    // MARK: - Public Configure
    func configure(with entity: PreferenceCardEntity) {
        let hasEnoughData = entity.keywords.count >= 3
        
        let dataViews = [cardImageView, keywordLabel, keywordCollectionView, summaryLabel, summaryTableView]
        let emptyViews = [emptyLabelUp, emptyLabelDown]
        
        dataViews.forEach { $0.isHidden = !hasEnoughData }
        emptyViews.forEach { $0.isHidden = hasEnoughData }
        
        // 필요 시 reload
        // keywordCollectionView.reloadData()
        // summaryTableView.reloadData()
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - UI
    private func setUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(emptyLabelUp)
        scrollView.addSubview(emptyLabelDown)
        scrollView.pin.all()
        contentView.pin.width(of: self)
        contentView.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = contentView.frame.size
        
        emptyLabelUp.pin.center().marginTop(-20)
        emptyLabelDown.pin.below(of: emptyLabelUp).marginTop(10).hCenter()
    }
}

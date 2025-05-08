//
//  KeywordView.swift
//  CulLecting
//
//  Created by 김승희 on 5/6/25.
//


import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then

final class KeywordView: UIView, UICollectionViewDelegate {
    private let keywordsRelay = BehaviorRelay<[String]>(value: [])
    private let disposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 문화 키워드"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .black
    }
    
    private let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 8
        $0.minimumLineSpacing = 8
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = true
        $0.register(KeywordCell.self, forCellWithReuseIdentifier: KeywordCell.identifier)
    }
    
    private let rootContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindCollection()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootContainer.pin.all()
        rootContainer.flex.layout(mode: .adjustHeight)
        self.frame.size.height = rootContainer.frame.maxY
    }
    
    private func setupUI() {
        addSubview(rootContainer)
        
        rootContainer.flex.direction(.column).define {
            $0.addItem(titleLabel).marginBottom(8)
            $0.addItem(collectionView).height(54)
        }
    }
    
    private func bindCollection() {
        keywordsRelay
            .bind(to: collectionView.rx.items(
                cellIdentifier: KeywordCell.identifier,
                cellType: KeywordCell.self
            )) { _, keyword, cell in
                cell.configure(with: keyword)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configure(keywords: [String]) {
        keywordsRelay.accept(keywords)
    }
}

//
//  SummaryView.swift
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


final class SummaryView: UIView {
    private let dataRelay = BehaviorRelay<[(String, String)]>(value:[])
    private let disposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.text = "나의 문화 소비 요약"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .black
    }
    
    private let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 15
        $0.sectionInset = .zero
        
        let totalWidth = UIScreen.main.bounds.width
        let cellWidth = totalWidth * 0.43
        $0.itemSize = CGSize(width: cellWidth, height: cellWidth * 0.7)
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.identifier)
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
            $0.addItem(collectionView).height(150)
        }
    }
    
    private func bindCollection() {
        dataRelay
            .bind(to: collectionView.rx.items(
                cellIdentifier: SummaryCell.identifier,
                cellType: SummaryCell.self
            )) { _, item, cell in
                cell.configure(title: item.0, value: item.1)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func configure(count: Int, category: String) {
        let data = [
            ("다녀온 문화행사 수", "\(count)개"),
            ("자주 찾은 분야", category)
        ]
        dataRelay.accept(data)
    }
}

extension SummaryView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let cellCount = 2
        let spacing: CGFloat = 12
        let totalCellWidth = (UIScreen.main.bounds.width) * 0.43 * CGFloat(cellCount)
        let totalSpacing = spacing * CGFloat(cellCount - 1)
        let contentWidth = totalCellWidth + totalSpacing
        let remaining = collectionView.bounds.width - contentWidth
        let inset = max(remaining / 2, 0)
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

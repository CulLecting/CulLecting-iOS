//
//  CulturalRecentContentSectionView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


final class CulturalRecentContentSectionView: UIView {
    
    // MARK: Properties
    private var categoryContents: [String: [CulturalContentEntity]] = [:]

    private let containerView = UIView()

    private let titleLabel = UILabel().then {
        $0.text = "최근 열린 문화 콘텐츠"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey90
    }

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
            layout.itemSize = CGSize(width: 200, height: 260)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            return layout
        }()
    ).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.register(CulturalRecentCell.self, forCellWithReuseIdentifier: CulturalRecentCell.identifier)
    }

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.pin.all(pin.safeArea)
        titleLabel.pin.top(0).horizontally(16).height(22)
        collectionView.pin.below(of: titleLabel).marginTop(8).height(260).horizontally()

        // 전체 높이 지정
        self.pin.height(collectionView.frame.maxY)
    }

    // MARK: Configure
    func configure(with categoryContents: [String: [CulturalContentEntity]]) {
        self.categoryContents = categoryContents
        collectionView.reloadData()
        setNeedsLayout()
    }
}

// MARK: - UICollectionViewDelegate, DataSource
extension CulturalRecentContentSectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(categoryContents.values.first?.count ?? 0, 3)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CulturalRecentCell.identifier,
            for: indexPath
        ) as? CulturalRecentCell else {
            return UICollectionViewCell()
        }

        if let firstCategory = categoryContents.values.first,
           indexPath.item < firstCategory.count {
            let content = firstCategory[indexPath.item]
            cell.configure(with: content)
        }
        return cell
    }
}

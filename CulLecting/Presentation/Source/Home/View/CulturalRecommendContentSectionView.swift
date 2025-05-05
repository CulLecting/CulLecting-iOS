//
//  CulturalRecommendContentSectionView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import Then


final class CulturalRecommendContentSectionView: UIView {

    // MARK: UI
    private let titleLabel = UILabel().then {
        $0.text = "오늘의 추천 콘텐츠"
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey90
    }

    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(CulturalContentHorizontalCell.self, forCellWithReuseIdentifier: CulturalContentHorizontalCell.identifier)
        
        if let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 140, height: 240)
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }

    // MARK: Data
    private var contents: [CulturalContentEntity] = []

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(collectionView)
        collectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.pin.top().horizontally(16).height(22)
        collectionView.pin.below(of: titleLabel).horizontally().marginTop(10).height(260)
        self.pin.height(collectionView.frame.maxY)
    }

    // MARK: Public
    func configure(with contents: [CulturalContentEntity]) {
        self.contents = contents
        collectionView.reloadData()
        setNeedsLayout()
    }
}

extension CulturalRecommendContentSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CulturalContentHorizontalCell.identifier, for: indexPath) as? CulturalContentHorizontalCell else {
            return UICollectionViewCell()
        }
        let item = contents[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

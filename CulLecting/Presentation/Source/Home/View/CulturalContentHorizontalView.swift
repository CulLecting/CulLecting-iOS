//
//  CulturalContentHorizontalView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import RxCocoa
import RxSwift


final class CulturalContentHorizontalView: UIView {

    // MARK: Properties
    private let disposeBag = DisposeBag()
    private var contents: [CulturalContentEntity] = []

    // MARK: UI Components
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 12
            layout.itemSize = CGSize(width: 140, height: 240)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            return layout
        }()
    ).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.register(CulturalContentHorizontalCell.self, forCellWithReuseIdentifier: CulturalContentHorizontalCell.identifier)
    }

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup
    private func setupUI() {
        addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.pin
            .top()
            .horizontally()
            .height(260)
        self.pin.height(collectionView.frame.maxY)
    }

    // MARK: Bind
    func configure(with contents: [CulturalContentEntity]) {
        self.contents = contents
        collectionView.reloadData()
        setNeedsLayout()
    }
}

// MARK: - CollectionView Delegate & DataSource
extension CulturalContentHorizontalView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CulturalContentHorizontalCell.identifier,
            for: indexPath
        ) as? CulturalContentHorizontalCell else {
            return UICollectionViewCell()
        }
        let content = contents[indexPath.item]
        cell.configure(with: content)
        return cell
    }
}

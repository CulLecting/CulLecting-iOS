//
//  CostCollectionView.swift
//  CulLecting
//
//  Created by SeungHwanMacBook on 5/8/25.
//

import UIKit
import SnapKit
import Then

class CostCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let cost = ["전체", "무료", "유료"]
    var selectedIndex: IndexPath? = IndexPath(item: 0, section: 0) // ✅ 기본값: '전체' 선택
    
    private let costLabel = UILabel().then {
        $0.text = "비용"
        $0.font = .fontPretendard(style: .title18SB)
    }
    
    private lazy var costCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false // ✅ 스크롤 비활성화
        collectionView.register(CostCell.self, forCellWithReuseIdentifier: CostCell.identifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        costCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        self.addSubview(costLabel)
        costLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        
        self.addSubview(costCollectionView)
        costCollectionView.snp.makeConstraints {
            $0.top.equalTo(costLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
    
    // MARK: - UICollectionView DataSource, Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cost.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CostCell.identifier, for: indexPath) as! CostCell
        cell.configure(with: cost[indexPath.item])
        // ✅ 선택된 셀만 색상 변경
        if indexPath == selectedIndex {
            cell.setSelected(true)
        } else {
            cell.setSelected(false)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width - 32 // 좌우 여백 (16 + 16)
        let spacing: CGFloat = 4 // 셀 간격
        let numberOfItemsPerRow: CGFloat = 4 // 한 줄에 3개
        
        // ✅ 동적 너비 계산
        let width = (totalWidth - (spacing * (numberOfItemsPerRow - 1))) / numberOfItemsPerRow
        return CGSize(width: width, height: 36)
    }
    
    // ✅ 선택 동작 (여기서 selectedIndex 변경)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Item: \(cost[indexPath.item])") // ✅ 선택된 아이템 로그
        selectedIndex = indexPath
        collectionView.reloadData() // ✅ 선택 상태를 업데이트
    }
    
    func getItem() -> String? {
        guard let indexPath = selectedIndex as IndexPath? else { return nil }
        return cost[indexPath.item]
    }
    
    func resetItem() {
        selectedIndex = IndexPath(item: 0, section: 0)
        costCollectionView.reloadData()
    }
}

class CostCell: UICollectionViewCell {
    static let identifier = "CostCell"

    private let keywordLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(keywordLabel)
        setupUI()
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
    }
    private func setupUI() {
        keywordLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(2)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-2)
            $0.top.equalTo(contentView.snp.top).offset(4)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        keywordLabel.text = text
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = .grey90
            keywordLabel.textColor = .white
        } else {
            contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            keywordLabel.textColor = .black
        }
    }
}

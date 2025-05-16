//
//  TicketListView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import Then
import PinLayout


final class TicketListView: UIView, UICollectionViewDelegate {
    
    // MARK: Properties
    private var tickets: [Ticket] = []

    // MARK: UI
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout()).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.dataSource = self
        $0.delegate = self
        $0.register(TicketCell.self, forCellWithReuseIdentifier: TicketCell.identifier)
    }

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }

    // MARK: Configure
    func configure(with tickets: [Ticket]) {
        self.tickets = tickets
        collectionView.reloadData()
    }

    // MARK: Layout
    private func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 140, height: 220)
        return layout
    }
}

// MARK: UICollectionViewDataSource
extension TicketListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.identifier, for: indexPath) as? TicketCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: tickets[indexPath.item])
        return cell
    }
}

// MARK: Cell
final class TicketCell: UICollectionViewCell {
    static let identifier = "TicketCell"

    private let templateView = TicketFrontView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(templateView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        templateView.frame = contentView.bounds
    }

    func configure(with ticket: Ticket) {
        templateView.configureCompact(with: ticket)
    }
}

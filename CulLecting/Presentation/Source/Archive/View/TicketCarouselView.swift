//  TicketCarouselView.swift
//  CulLecting
//
//  Created by 김승희 on 2025/04/15.
//  Refactored to UICollectionView




import UIKit

import FlexLayout
import PinLayout
import Then


final class TicketCarouselView: UIView {

    // MARK: Properties
    private var tickets: [Ticket] = []

    var scrollCallback: ((Int) -> Void)?
    var onTicketTapped: ((Ticket) -> Void)?

    private let cardSpacing: CGFloat = 10

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = cardSpacing
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.clipsToBounds = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(TicketCarouselCell.self, forCellWithReuseIdentifier: TicketCarouselCell.identifier)
        return cv
    }()

    private var didLayoutCards = false

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(collectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.pin.all()

        if collectionView.bounds.width > 0, !didLayoutCards {
            updateLayout()
            scrollToIndex(index: 0, animated: false)
            didLayoutCards = true
        }
    }

    // MARK: Config
    func configure(with tickets: [Ticket]) {
        self.tickets = tickets
        self.didLayoutCards = false
        collectionView.reloadData()
        setNeedsLayout()
    }

    //MARK: CollectionView 레이아웃 관련
    private func updateLayout() {
        let cardHeight = bounds.height * 0.85
        let cardWidth = cardHeight * 0.62

        flowLayout.itemSize = CGSize(width: cardWidth, height: cardHeight)

        let spacer = (bounds.width - cardWidth) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: spacer, bottom: 0, right: spacer)

        collectionView.collectionViewLayout.invalidateLayout()
        updateTransforms()
    }

    private func scrollToIndex(index: Int, animated: Bool) {
        guard index >= 0, index < tickets.count else { return }

        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        scrollCallback?(index)
    }
}

// MARK: - UICollectionViewDataSource
extension TicketCarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TicketCarouselCell.identifier,
            for: indexPath
        ) as? TicketCarouselCell else {
            return UICollectionViewCell()
        }

        let ticket = tickets[indexPath.item]
        cell.configure(with: ticket)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TicketCarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ticket = tickets[indexPath.item]
        onTicketTapped?(ticket)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTransforms()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToNearestCard()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            snapToNearestCard()
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cardHeight = bounds.height * 0.85
        let cardWidth = cardHeight * 0.62
        let totalWidth = cardWidth + cardSpacing

        let centerOffset = targetContentOffset.pointee.x + bounds.width / 2

        let index = round((centerOffset - collectionView.contentInset.left - cardWidth / 2) / totalWidth)
        let clampedIndex = max(0, min(CGFloat(tickets.count - 1), index))

        let targetX = clampedIndex * totalWidth + collectionView.contentInset.left + cardWidth / 2 - bounds.width / 2

        targetContentOffset.pointee.x = targetX

        scrollCallback?(Int(clampedIndex))
    }

    private func updateTransforms() {
        let centerX = collectionView.bounds.midX

        for cell in collectionView.visibleCells {
            let cellCenter = collectionView.convert(cell.center, to: collectionView)

            let distance = abs(centerX - cellCenter.x)
            let maxDistance = bounds.width / 2 + cell.bounds.width / 2
            let ratio = min(distance / maxDistance, 1)

            let scale = 1 - ratio * 0.1
            let alpha = 1 - ratio * 0.5

            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            cell.alpha = alpha
        }
    }


    private func snapToNearestCard() {
        let cardHeight = bounds.height * 0.85
        let cardWidth = cardHeight * 0.62
        let totalWidth = cardWidth + cardSpacing

        let centerOffset = collectionView.contentOffset.x + bounds.width / 2
        let index = round((centerOffset - collectionView.contentInset.left - cardWidth / 2) / totalWidth)
        let clampedIndex = Int(max(0, min(CGFloat(tickets.count - 1), index)))

        scrollToIndex(index: clampedIndex, animated: true)
    }
}

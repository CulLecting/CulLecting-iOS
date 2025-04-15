//  TicketCarouselView.swift
//  CulLecting
//
//  Created by 김승희 on 2025/04/15.

import UIKit

import FlexLayout
import PinLayout
import Then

final class TicketCarouselView: UIView, UIScrollViewDelegate {

    // MARK: - Properties
    private var tickets: [Ticket] = []
    private var cardViews: [TicketView] = []
    private let cardWidthRatio: CGFloat = 0.7
    private let cardHeightRatio: CGFloat = 0.8
    private let cardSpacing: CGFloat = 10

    var onCardTapped: ((Ticket) -> Void)?
    var scrollCallback: ((Int) -> Void)?

    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = false
        $0.decelerationRate = .fast
        $0.clipsToBounds = false
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(with tickets: [Ticket]) {
        self.tickets = tickets
        setNeedsLayout() // ⚠️ 이건 호출하되
        DispatchQueue.main.async {
            self.layoutCards() // view의 bounds가 설정된 이후 안전하게 호출
        }
    }

    // MARK: - UI Setup
    private func setup() {
        addSubview(scrollView)
        scrollView.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
    }

    private func layoutCards() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()

        let cardWidth = bounds.width * cardWidthRatio
        let cardHeight = bounds.height * cardHeightRatio
        let yOffset = (bounds.height - cardHeight) / 2

        for (index, ticket) in tickets.enumerated() {
            let cardView = TicketView(ticket: ticket)
            cardView.frame = CGRect(
                x: CGFloat(index) * (cardWidth + cardSpacing),
                y: yOffset,
                width: cardWidth,
                height: cardHeight
            )
            cardView.layer.cornerRadius = 20
            cardView.clipsToBounds = true
            cardView.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
            cardView.addGestureRecognizer(tap)

            scrollView.addSubview(cardView)
            cardViews.append(cardView)
        }

        scrollView.contentSize = CGSize(
            width: CGFloat(tickets.count) * (cardWidth + cardSpacing),
            height: bounds.height
        )

        updateTransforms()
        scrollToIndex(index: 0, animated: false)
    }

    // MARK: - Transform Logic
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

    private func updateTransforms() {
        let centerX = scrollView.contentOffset.x + bounds.width / 2

        for cardView in cardViews {
            let baseCenter = cardView.center.x
            let distance = abs(centerX - baseCenter)
            let maxDistance = bounds.width / 2 + cardView.bounds.width / 2
            let scale = max(0.9, 1 - distance / maxDistance * 0.1)
            let alpha = max(0.5, 1 - distance / maxDistance)

            cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
            cardView.alpha = alpha
        }
    }

    private func snapToNearestCard() {
        let cardWidth = bounds.width * cardWidthRatio
        let totalWidth = cardWidth + cardSpacing
        let centerOffset = scrollView.contentOffset.x + bounds.width / 2
        let index = Int(round((centerOffset - cardWidth / 2) / totalWidth))
        scrollToIndex(index: index, animated: true)
        scrollCallback?(index)
    }

    private func scrollToIndex(index: Int, animated: Bool) {
        let cardWidth = bounds.width * cardWidthRatio
        let targetX = CGFloat(index) * (cardWidth + cardSpacing) - (bounds.width - cardWidth) / 2
        scrollView.setContentOffset(CGPoint(x: max(0, targetX), y: 0), animated: animated)
    }

    // MARK: - Card Tap Handler
    @objc private func handleCardTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? TicketView,
              let index = cardViews.firstIndex(of: view) else { return }
        let ticket = tickets[index]
        onCardTapped?(ticket)
    }
}

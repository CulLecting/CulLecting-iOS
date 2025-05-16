//  TicketCarouselView.swift
//  CulLecting
//
//  Created by 김승희 on 2025/04/15.




import UIKit

import FlexLayout
import PinLayout
import Then


final class TicketCarouselView: UIView, UIScrollViewDelegate {
    
    // MARK: Properties
    private var tickets: [Ticket] = []
    private var cardViews: [TicketFrontView] = []
    
    var scrollCallback: ((Int) -> Void)?
    var onTicketTapped: ((Ticket) -> Void)?
    
    private let cardSpacing: CGFloat = 10
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = false
        $0.decelerationRate = .fast
        $0.clipsToBounds = false
    }
    
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
        addSubview(scrollView)
        scrollView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all()
        
        if scrollView.bounds.width > 0, !didLayoutCards {
            layoutCards()
            scrollToIndex(index: 0, animated: false)
            didLayoutCards = true
        }
    }
    
    // MARK: Config
    func configure(with tickets: [Ticket]) {
        self.tickets = tickets
        self.didLayoutCards = false
        setNeedsLayout()
    }
    
    //MARK: Ticket Carouselview 레이아웃 관련
    private func layoutCards() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        
        let cardHeight = bounds.height * 0.85
        let cardWidth = cardHeight * 0.62
        let yOffset = (bounds.height - cardHeight) / 2
        let spacer = (bounds.width - cardWidth) / 2
        
        for (index, ticket) in tickets.enumerated() {
            let xPosition = spacer + CGFloat(index) * (cardWidth + cardSpacing)
            
            let cardView = TicketFrontView(ticket: ticket)
            cardView.frame = CGRect(
                x: xPosition,
                y: yOffset,
                width: cardWidth,
                height: cardHeight
            )
            cardView.layer.cornerRadius = 20
            cardView.clipsToBounds = true
            
            scrollView.addSubview(cardView)
            cardViews.append(cardView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTicketTap(_:)))
            cardView.addGestureRecognizer(tap)
            cardView.isUserInteractionEnabled = true
        }
        
        let totalCardWidth = CGFloat(tickets.count) * (cardWidth + cardSpacing) - cardSpacing
        scrollView.contentSize = CGSize(width: spacer + totalCardWidth, height: bounds.height)
        scrollView.contentInset = .zero
        
        updateTransforms()
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
        let cardHeight = bounds.height * 0.85
        let cardWidth = cardHeight * 0.62
        let totalWidth = cardWidth + cardSpacing
        let spacer = (bounds.width - cardWidth) / 2

        let centerOffset = scrollView.contentOffset.x + bounds.width / 2
        let adjustedOffset = centerOffset - spacer

        let index = Int(round((adjustedOffset - cardWidth / 2) / totalWidth))
        scrollToIndex(index: index, animated: true)
    }

    private func scrollToIndex(index: Int, animated: Bool) {
        let cardHeight = bounds.height * 0.85
        let cardWidth = cardHeight * 0.62
        let spacer = (bounds.width - cardWidth) / 2

        let cardX = spacer + CGFloat(index) * (cardWidth + cardSpacing)
        let targetX = cardX - (bounds.width - cardWidth) / 2

        scrollView.setContentOffset(CGPoint(x: max(0, targetX), y: 0), animated: animated)
        scrollCallback?(index)
    }
    
    //MARK: 티켓 핸들러
    @objc private func handleTicketTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? TicketFrontView,
              let index = cardViews.firstIndex(of: view) else { return }
        print("티켓 클릭됨")
        let ticket = tickets[index]
        onTicketTapped?(ticket)
    }
}

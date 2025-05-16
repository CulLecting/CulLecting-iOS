//
//  TicketSegmentView.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


final class TicketSegmentView: UIView {
    var onTicketTapped: ((Ticket) -> Void)?
    
    // MARK: UI Components
    private let rootFlexContainer = UIView()
    private let ticketView = TicketCarouselView()
    
    private let indexContainer = UIView().then {
        $0.backgroundColor = UIColor.grey20
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let indexLabel = UILabel().then {
        $0.textColor = .grey90
        $0.font = .fontPretendard(style: .body14M)
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.lineBreakMode = .byClipping
        $0.text = "1 / 1"
    }
    
    private let addImageView = UIImageView(image: UIImage.addCullecting).then {
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ticketView.onTicketTapped = { [weak self] ticket in
            self?.cardTapped(ticket)
        }
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        self.frame.size.height = rootFlexContainer.frame.maxY
    }
    
    // MARK: Public
    func configure(with tickets: [Ticket]) {
        let hasTickets = !tickets.isEmpty
        ticketView.flex.isIncludedInLayout(hasTickets)
        indexContainer.flex.isIncludedInLayout(hasTickets)
        addImageView.flex.isIncludedInLayout(!hasTickets)
        addImageView.isHidden = hasTickets
        
        if hasTickets {
            ticketView.configure(with: tickets)
            indexLabel.text = "1 / \(tickets.count)"
            ticketView.scrollCallback = { [weak self] index in
                self?.indexLabel.text = "\(index + 1) / \(tickets.count)"
            }
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func cardTapped(_ ticket: Ticket) {
        onTicketTapped?(ticket)
    }
    
    // MARK: Setup
    private func setupUI() {
        addSubview(rootFlexContainer)
        
        indexContainer.addSubview(indexLabel)
        
        rootFlexContainer.flex.direction(.column).alignItems(.center).define {
            $0.addItem(ticketView)
                .marginTop(0)
                .width(100%)
                .height(500)
            
            $0.addItem(indexContainer)
                .marginTop(20)
                .width(60)
                .height(48)
                .justifyContent(.center)
                .alignItems(.center)
                .define {
                    $0.addItem(indexLabel)
                        .width(100%)
                        .height(100%)
                }
            
            $0.addItem(addImageView)
                .marginTop(40)
                .width(90%)
                .aspectRatio(1.03)
        }
    }
}

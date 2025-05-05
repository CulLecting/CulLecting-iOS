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
    
    // MARK: UI Components
    private let rootFlexContainer = UIView()
    
    private let ticketView = TicketCarouselView()
    
    private let indexLabel = UILabel().then {
        $0.textColor = .grey60
        $0.font = .fontPretendard(style: .body14M)
        $0.textAlignment = .center
    }
    
    private let addImageView = UIImageView(image: UIImage.addCullecting).then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
    }

    // MARK: Public
    func configure(with tickets: [Ticket]) {
        let hasTickets = !tickets.isEmpty
        ticketView.isHidden = !hasTickets
        indexLabel.isHidden = !hasTickets
        addImageView.isHidden = hasTickets
        
        if hasTickets {
            ticketView.configure(with: tickets)
            indexLabel.text = "1 / \(tickets.count)"
            ticketView.scrollCallback = { [weak self] index in
                self?.indexLabel.text = "\(index + 1) / \(tickets.count)"
            }
        }
    }

    // MARK: Setup
    private func setupUI() {
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.direction(.column).alignItems(.center).define {
            $0.addItem(ticketView)
                .marginTop(0)
                .width(100%)
                .height(500)
            
            $0.addItem(indexLabel)
                .marginTop(20)
            
            $0.addItem(addImageView)
                .marginTop(40)
                .width(180)
                .height(180)
        }
    }
}

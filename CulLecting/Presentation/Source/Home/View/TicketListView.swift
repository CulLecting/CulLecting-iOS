//
//  TicketListView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit


final class TicketListView: UIView {
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
        
        if let firstSubview = stackView.arrangedSubviews.first {
            self.pin.height(of: firstSubview).marginTop(0).marginBottom(0)
        }
    }

    func configure(with tickets: [Ticket]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        tickets.forEach { ticket in
            let ticketView = TicketTemplateView(ticket: ticket)
            ticketView.layer.cornerRadius = 16
            ticketView.clipsToBounds = true
            stackView.addArrangedSubview(ticketView)
        }
    }
}

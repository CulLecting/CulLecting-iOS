//
//  TicketCarouselCell.swift
//  CulLecting
//
//  Created for CollectionView refactoring
//

import UIKit

import PinLayout

final class TicketCarouselCell: UICollectionViewCell {

    static let identifier = "TicketCarouselCell"

    private let ticketFrontView = TicketFrontView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(ticketFrontView)
        ticketFrontView.layer.cornerRadius = 20
        ticketFrontView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ticketFrontView.pin.all()
    }

    func configure(with ticket: Ticket) {
        ticketFrontView.configure(with: ticket)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ticketFrontView.transform = .identity
        ticketFrontView.alpha = 1.0
    }
}

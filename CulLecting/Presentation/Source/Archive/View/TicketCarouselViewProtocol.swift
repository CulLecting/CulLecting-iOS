//
//  TicketCarouselViewProtocol.swift
//  CulLecting
//
//  Protocol for interchangeable carousel implementations
//

import UIKit

protocol TicketCarouselViewProtocol: UIView {
    var scrollCallback: ((Int) -> Void)? { get set }
    var onTicketTapped: ((Ticket) -> Void)? { get set }

    func configure(with tickets: [Ticket])
}

// MARK: - Factory
enum CarouselType {
    case scrollView
    case collectionView
}

enum TicketCarouselFactory {
    static func make(type: CarouselType) -> TicketCarouselViewProtocol {
        switch type {
        case .scrollView:
            return TicketCarouselScrollView()
        case .collectionView:
            return TicketCarouselCollectionView()
        }
    }
}

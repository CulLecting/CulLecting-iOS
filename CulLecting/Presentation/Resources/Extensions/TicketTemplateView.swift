//
//  TicketTemplateView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import Then
import FlexLayout
import PinLayout


final class TicketTemplateView: UIView {
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    convenience init(ticket: Ticket) {
        self.init(frame: .zero)
        configure(with: ticket)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds
        titleLabel.frame = CGRect(x: 16, y: bounds.height - 60, width: bounds.width - 32, height: 22)
        dateLabel.frame = CGRect(x: 16, y: bounds.height - 32, width: bounds.width - 32, height: 20)
    }
    
    // MARK: Setup
    private func setupUI() {
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(dateLabel)

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .white
    }
    
    // MARK: Config
    func configure(with ticket: Ticket) {
        titleLabel.text = ticket.title
        dateLabel.text = ticket.date
        
        switch ticket.template {
        case .basic:
            if let url = URL(string: ticket.imageURL) {
                loadImage(url) { [weak self] image in
                    self?.backgroundImageView.image = image
                    if ticket.averageColorHex.isEmpty,
                       let avg = image?.averageColor() {
                        self?.backgroundColor = avg.withAlphaComponent(0.6)
                    }
                }
            }
        default:
            backgroundImageView.image = UIImage.templateWhite
        }
    }

    private func loadImage(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap { UIImage(data: $0) }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

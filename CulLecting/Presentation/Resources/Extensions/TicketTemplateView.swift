//
//  TicketTemplateView.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit

import FlexLayout
import Kingfisher
import PinLayout
import Then


// MARK: - 공통 배경 뷰
class TicketBackgroundView: UIView {

    let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
    }

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
        $0.clipsToBounds = true
    }

    var blurContentView: UIView {
        return blurView.contentView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBackground() {
        layer.cornerRadius = 20
        clipsToBounds = true

        addSubview(backgroundImageView)
        backgroundImageView.addSubview(blurView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.pin.all()
        blurView.pin.all()
    }

    func setBackground(from ticket: Ticket) {
        // imageURL이 full URL이면 그대로 사용, 아니면 서버 URL 붙이기
        let urlString = ticket.imageURL.hasPrefix("http") ? ticket.imageURL : "https://cullecting.site\(ticket.imageURL)"

        if let url = URL(string: urlString) {
            backgroundImageView.kf.setImage(with: url, completionHandler: { [weak self] result in
                guard let self = self, case .success(let value) = result else { return }

                // averageColorHex가 비어있으면 이미지에서 평균 색상 계산
                if ticket.averageColorHex.isEmpty,
                   let avg = value.image.averageColor() {
                    self.blurView.backgroundColor = avg.withAlphaComponent(0.6)
                } else if !ticket.averageColorHex.isEmpty {
                    // averageColorHex가 있으면 해당 색상 사용
                    self.blurView.backgroundColor = UIColor(hex: ticket.averageColorHex)?.withAlphaComponent(0.6)
                }
            })
        }
    }
}

//MARK: 카드 앞면
final class TicketFrontView: TicketBackgroundView {

    // MARK: UI
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private let titleLabel = UILabel().then {
        $0.font = .fontPretendard(style: .title18B)
        $0.textColor = .grey90
        $0.textAlignment = .center
    }

    private let dateLabel = UILabel().then {
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey90
        $0.textAlignment = .center
    }

    private let labelContainer = UIView()

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    convenience init(ticket: Ticket) {
        self.init(frame: .zero)
        configure(with: ticket)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup
    private func setupSubviews() {
        labelContainer.flex
            .direction(.column)
            .alignItems(.center)
            .define {
                $0.addItem(titleLabel).marginBottom(4)
                $0.addItem(dateLabel)
            }

        blurContentView.addSubview(thumbnailImageView)
        blurContentView.addSubview(labelContainer)
    }

    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        let margin = bounds.height * 0.03

        thumbnailImageView.pin
            .top(margin)
            .left(margin)
            .right(margin)
            .height(bounds.height * 0.79)

        thumbnailImageView.layer.cornerRadius = thumbnailImageView.bounds.width * 0.17

        labelContainer.pin
            .below(of: thumbnailImageView, aligned: .center)
            .marginTop(bounds.height * 0.05)
            .width(of: self)

        labelContainer.flex.layout(mode: .adjustHeight)
    }

    // MARK: Configure
    func configure(with ticket: Ticket) {
        titleLabel.font = .fontPretendard(style: .title18B)
        dateLabel.font = .fontPretendard(style: .body14M)
        applyTicketData(ticket)
    }

    func configureCompact(with ticket: Ticket) {
        titleLabel.flex.isIncludedInLayout(false)
        titleLabel.isHidden = true
        dateLabel.font = .fontPretendard(style: .caption11R)
        applyTicketData(ticket)
    }

    private func applyTicketData(_ ticket: Ticket) {
        titleLabel.text = ticket.title
        dateLabel.text = ticket.date
        setBackground(from: ticket)

        // imageURL이 full URL이면 그대로 사용, 아니면 서버 URL 붙이기
        let urlString = ticket.imageURL.hasPrefix("http") ? ticket.imageURL : "https://cullecting.site\(ticket.imageURL)"

        if let url = URL(string: urlString) {
            thumbnailImageView.kf.setImage(with: url)
        }
    }
}


// MARK: - 카드 뒷면
final class TicketBackView: TicketBackgroundView {

    // MARK: UI
    private let titleLabel = UILabel().then {
        $0.font = .fontPretendard(style: .title18B)
        $0.textColor = .grey90
        $0.textAlignment = .left
    }

    private let dateLabel = UILabel().then {
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey90
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.lineBreakMode = .byClipping
    }

    private let descriptionBox = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }

    private let descriptionLabel = UILabel().then {
        $0.font = .fontPretendard(style: .body14R)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }

    private let iconImageView = UIImageView(image: UIImage(named: "cullectingIconBlack")).then {
        $0.contentMode = .scaleAspectFit
    }

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    convenience init(ticket: Ticket) {
        self.init(frame: .zero)
        configure(with: ticket)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup
    private func setupSubviews() {
        descriptionBox.addSubview(descriptionLabel)

        blurContentView.addSubview(titleLabel)
        blurContentView.addSubview(dateLabel)
        blurContentView.addSubview(descriptionBox)
        blurContentView.addSubview(iconImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let padding: CGFloat = 20
        let width = bounds.width
        let height = bounds.height

        titleLabel.pin
            .top(padding)
            .left(padding)
            .sizeToFit()

        dateLabel.pin
            .below(of: titleLabel, aligned: .left)
            .width(100%)
            .marginTop(4)
            .sizeToFit()

        descriptionBox.pin
            .below(of: dateLabel)
            .marginTop(20)
            .hCenter()
            .width(width * 0.9)
            .height(height * 0.7)

        descriptionLabel.pin
            .top(16)
            .horizontally(16)
            .sizeToFit(.width)

        iconImageView.pin
            .below(of: descriptionBox)
            .marginTop(12)
            .hCenter()
            .width(32)
            .height(32)
    }

    // MARK: Configure
    func configure(with ticket: Ticket) {
        titleLabel.text = ticket.title
        dateLabel.text = ticket.date
        descriptionLabel.text = ticket.description
        setBackground(from: ticket)
    }
}

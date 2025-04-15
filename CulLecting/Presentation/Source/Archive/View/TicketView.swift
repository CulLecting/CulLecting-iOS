//
//  TicketView.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//

import UIKit

import FlexLayout
import PinLayout
import Then

final class TicketView: UIView {

    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
        $0.clipsToBounds = true
    }
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .center
        $0.textColor = .black
        $0.text = "행사 제목"
    }
    private lazy var dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = .darkGray
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        $0.text = formatter.string(from: ticket.attendAt)
    }
    private let labelContainer = UIView()
    
    private let backTextView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    private let backTextLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14)
    }

    private var isFront = true
    var ticket: Ticket

    // MARK: - LifeCycle

    init(ticket: Ticket) {
        self.ticket = ticket
        super.init(frame: .zero)
        setupUI()
        configure(with: ticket)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0, bounds.height > 0 else { return }

        backgroundImageView.pin.all()
        blurView.pin.all()

        let horizontalPadding: CGFloat = 20
        let thumbTop: CGFloat = 20
        let thumbBottom = bounds.height * 0.75
        let thumbHeight = max(thumbBottom - thumbTop, 0)

        thumbnailImageView.pin
            .top(thumbTop)
            .horizontally(horizontalPadding)
            .height(thumbHeight)

        labelContainer.pin
            .below(of: thumbnailImageView, aligned: .center)
            .marginTop(12)
            .width(of: self)
        labelContainer.flex.layout(mode: .adjustHeight)

        backTextView.pin
            .hCenter()
            .vCenter()
            .width(bounds.width - horizontalPadding * 2)
            .height(bounds.height * 0.75)

        backTextLabel.frame = backTextView.bounds.insetBy(dx: 12, dy: 12)
    }

    // MARK: - UI

    private func setupUI() {
        layer.cornerRadius = 20
        clipsToBounds = true
        addSubview(backgroundImageView)
        backgroundImageView.addSubview(blurView)
        blurView.contentView.addSubview(thumbnailImageView)
        
        labelContainer.flex
            .direction(.column)
            .alignItems(.center)
            .define {
            $0.addItem(titleLabel).marginBottom(4)
            $0.addItem(dateLabel)
        }
        
        blurView.contentView.addSubview(labelContainer)
        backTextView.addSubview(backTextLabel)
        blurView.contentView.addSubview(backTextView)
    }

    // MARK: - Configure

    func configure(with ticket: Ticket) {
        self.ticket = ticket

        if let url = URL(string: ticket.poster) {
            loadImage(from: url) { [weak self] image in
                self?.backgroundImageView.image = image
                self?.thumbnailImageView.image = image
            }
        }

        if let blurColor = UIColor(hex: ticket.averageColorHex) {
            blurView.backgroundColor = blurColor.withAlphaComponent(0.6)
        }

        backTextLabel.text = ticket.backText

        updateViewState(animated: false)
    }

    func update(ticket: Ticket) {
        configure(with: ticket)
    }

    func flip() {
        isFront.toggle()
        updateViewState(animated: true)
        //animateFlip()
    }

    /// 뷰자체가 뒤집어지는데 약간 그림자같은게 보임
    private func updateViewState(animated: Bool) {
        let showFront = isFront

        thumbnailImageView.isHidden = !showFront
        labelContainer.isHidden = !showFront
        backTextView.isHidden = showFront

        if animated {
            UIView.transition(with: self, duration: 0.5, options: [.transitionFlipFromLeft], animations: nil)
        }
    }
    
    /// 얘는 더 스무스하긴 한데 뷰 자체가 뒤집어지진 않음
    private func animateFlip() {
        let fromView = isFront ? backTextView : thumbnailImageView
        let toView = isFront ? thumbnailImageView : backTextView
        
        toView.isHidden = false
        labelContainer.isHidden = !isFront
        fromView.layer.isDoubleSided = false
        toView.layer.isDoubleSided = false
        
        UIView.transition(from: fromView, to: toView,
                          duration: 0.4,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews],
                          completion: nil)
    }
    
    // MARK: - 이미지 로딩

    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            DispatchQueue.main.async {
                self.backgroundImageView.image = image
                self.thumbnailImageView.image = image

                if self.ticket.averageColorHex.isEmpty,
                   let avgColor = image.averageColor() {
                    self.blurView.backgroundColor = avgColor.withAlphaComponent(0.6)
                }

                completion(image)
            }
        }.resume()
    }
}

//
//  ArchiveViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/13/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


class ArchiveViewController: UIViewController {
    
    private let ticketView = TicketCarouselView()
    
    private let indexLabel = UILabel().then {
        $0.textColor = .grey60
        $0.font = .fontPretendard(style: .body14M)
        $0.textAlignment = .center
        $0.text = "1/10"
    }
    
    let dummyTickets: [Ticket] = [
        Ticket(
            id: UUID(),
            attendAt: Date(),
            poster: "https://picsum.photos/id/1011/300/400",
            averageColorHex: "#A7C5BD",
            backText: "서울에서의 감동적인 하루"
        ),
        Ticket(
            id: UUID(),
            attendAt: Date(),
            poster: "https://picsum.photos/id/1012/300/400",
            averageColorHex: "#FFE0AC",
            backText: "혼자만의 시간을 보냈다"
        ),
        Ticket(
            id: UUID(),
            attendAt: Date(),
            poster: "https://picsum.photos/id/1013/300/400",
            averageColorHex: "#D5A6BD",
            backText: "소중한 친구들과의 추억"
        ),
        Ticket(
            id: UUID(),
            attendAt: Date(),
            poster: "https://picsum.photos/id/1014/300/400",
            averageColorHex: "#C9DAE1",
            backText: "다시 보고 싶은 영화 🎬"
        ),
        Ticket(
            id: UUID(),
            attendAt: Date(),
            poster: "https://picsum.photos/id/1015/300/400",
            averageColorHex: "#B0C4DE",
            backText: "기억하고 싶은 하루"
        )]
    
    private let floatingButton = UIButton().then {
        $0.setTitle("＋", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 27, weight: .bold)
        $0.backgroundColor = .grey90
        $0.layer.borderWidth = 0
        $0.layer.cornerRadius = 27
    }
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setUI()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setLayout()
    }
    
    //MARK: 기타 메서드
    private func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "내 기록"
    }
    
    private func setAction() {
        let floatingButtonAction = UIAction { [ weak self ] _ in
            let makeTicketVC = MakeTicketViewController()
            self?.navigationController?.pushViewController(makeTicketVC, animated: true)
        }
        floatingButton.addAction(floatingButtonAction, for: .touchUpInside)
    }
    
    //MARK: UI
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(ticketView)
        view.addSubview(indexLabel)
        view.addSubview(floatingButton)
        
        let limitedTickets = Array(dummyTickets.prefix(10))
        ticketView.configure(with: limitedTickets)
        
        ticketView.onCardTapped = { [weak self] ticket in
            let detailVC = TicketDetailViewController(ticket: ticket)
            self?.navigationController?.pushViewController(detailVC, animated: true)
        }
        
        ticketView.scrollCallback = { [weak self] index in
            self?.indexLabel.text = "\(index + 1) / 10"
        }
        
        setAction()
    }
    
    private func setLayout() {
        ticketView.pin
            .top(view.pin.safeArea.top + 32)
            .horizontally(20)
            .height(500)
        
        indexLabel.pin
            .below(of: ticketView)
            .marginTop(20)
            .hCenter()
            .sizeToFit(.width)
        
        floatingButton.pin
            .bottom(view.pin.safeArea.bottom + 20)
            .right(20)
            .width(54)
            .height(54)
    }
}

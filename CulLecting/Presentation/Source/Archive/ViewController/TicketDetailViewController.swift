//
//  TicketDetailViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//

import UIKit
import FlexLayout
import PinLayout
import Then

class TicketDetailViewController: UIViewController {

    // MARK: - Properties
    private var ticket: Ticket
    private let rootContainer = UIView()

    private lazy var ticketView = TicketView(ticket: ticket).then {
        $0.isUserInteractionEnabled = true
    }

    private let rotateImageView = UIImageView(image: UIImage.rotateButton)

    private let modalPreviewView = UIView().then {
        $0.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }

    // MARK: - Init
    init(ticket: Ticket) {
        self.ticket = ticket
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        setUI()
        addTapGestureToCard()
        addEditModalGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootContainer.pin.all(view.pin.safeArea)
        rootContainer.flex.layout()

        modalPreviewView.pin
            .bottom()
            .horizontally()
            .height(100)
    }

    // MARK: - Setup
    private func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)

        let backAction = UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            primaryAction: backAction,
            menu: nil
        )
        backButton.tintColor = UIColor.grey90
        navigationItem.leftBarButtonItem = backButton

        let rightAction = UIAction { [weak self] _ in
            guard let self = self else { return }

            let image = self.ticketView.snapshotImage()
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem

            self.present(activityVC, animated: true)
        }

        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            primaryAction: rightAction,
            menu: nil
        )
        rightButton.tintColor = UIColor.grey90
        navigationItem.rightBarButtonItem = rightButton
    }

    private func setUI() {
        view.addSubview(rootContainer)
        view.addSubview(modalPreviewView)

        rootContainer.flex
            .direction(.column)
            .alignItems(.center)
            .paddingHorizontal(20)
            .define {
                $0.addItem(ticketView)
                    .width(80%)
                    .height(400)
                    .marginTop(20)
                $0.addItem(rotateImageView)
                    .width(32)
                    .height(48)
                    .marginTop(16)
            }
    }

    private func addTapGestureToCard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardFlip))
        ticketView.addGestureRecognizer(tap)
    }

    @objc private func handleCardFlip() {
        ticketView.flip()
    }

    private func addEditModalGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEditModal))
        modalPreviewView.addGestureRecognizer(tapGesture)
        modalPreviewView.isUserInteractionEnabled = true
    }

    @objc private func handleEditModal() {
        let editVC = TicketEditViewController(ticket: self.ticket)
        editVC.onSave = { [weak self] updatedTicket in
            guard let self = self else { return }
            self.ticket = updatedTicket
            self.ticketView.update(ticket: updatedTicket)
        }

        if let sheet = editVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(editVC, animated: true)
    }
}

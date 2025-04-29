//
//  SearchTicketInfoViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import FlexLayout
import Kingfisher
import PinLayout
import RxCocoa
import RxSwift
import Then


final class SearchTicketInfoViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: SearchTicketInfoViewModel
    private weak var coordinator: ArchiveCoordinator?
    private let actionType: TicketActionType
    private let disposeBag = DisposeBag()
    private let selectedImageRelay = PublishRelay<UIImage>()
    
    private var tickets: [Ticket] = []
    private var lastSearchText: String = ""

    // MARK: UI Components
    private let searchBar = UISearchBar().then {
        $0.placeholder = "검색어를 입력해주세요"
        $0.searchBarStyle = .minimal
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.register(TicketCell.self, forCellWithReuseIdentifier: TicketCell.identifier)
    }
    
    // MARK: Init
    init(viewModel: SearchTicketInfoViewModel, coordinator: ArchiveCoordinator, actionType: TicketActionType) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.actionType = actionType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        setupUI()
        bindViewModel()
    }
}

// MARK: - Bindings
private extension SearchTicketInfoViewController {
    
    private func bindViewModel() {
        let input = SearchTicketInfoViewModel.Input(
            searchTrigger: searchBar.rx.searchButtonClicked.asObservable(),
            searchText: searchBar.rx.text.orEmpty.asObservable(),
            selectImage: selectedImageRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.searchResults
            .drive(onNext: { [weak self] tickets in
                guard let self else { return }
                self.tickets = tickets
                if tickets.isEmpty {
                    self.showAlert(title: "검색 결과 없음", message: "검색된 데이터가 없습니다.\n다른 검색어를 입력해보세요.")
                }
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive()
            .disposed(by: disposeBag)
        
        output.uploadCompleted
            .emit(onNext: { [weak self] ticket in
                self?.coordinator?.showTicketDetail(from: ticket)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(onNext: { [weak self] text in
                self?.lastSearchText = text
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Setup
private extension SearchTicketInfoViewController {
    
    func setNavigationBar() {
        navigationItem.title = "이미지 검색"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(popViewController)
        )
    }
    
    @objc func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        searchBar.pin
            .top(view.pin.safeArea.top)
            .horizontally()
            .height(50)
        
        collectionView.pin
            .below(of: searchBar)
            .horizontally()
            .bottom()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 40) / 2, height: 200)
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


//MARK: CollectionView
extension SearchTicketInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tickets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TicketCell.identifier, for: indexPath) as? TicketCell else {
            return UICollectionViewCell()
        }
        let ticket = tickets[indexPath.item]
        cell.configure(with: ticket)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ticket = tickets[indexPath.item]
        
        if let url = URL(string: ticket.imageURL) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        switch self.actionType {
                        case .create:
                            self.selectedImageRelay.accept(value.image)
                        case .edit(let ticket):
                            self.updateTicketImage(ticketId: ticket.id, newImage: value.image)
                        }
                    }
                case .failure(let error):
                    print("이미지 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}


//MARK: 기타 메서드
extension SearchTicketInfoViewController {
    private func updateTicketImage(ticketId: String, newImage: UIImage) {
        let useCase = coordinator?.injector.resolve(ArchivingUseCase.self)
        
        useCase?.updateImage(id: ticketId, image: newImage)
            .andThen(useCase!.fetchTicket(id: ticketId))
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] updatedTicket in
                self?.coordinator?.showTicketDetail(from: updatedTicket)
            }, onFailure: { error in
                print("티켓 이미지 수정 실패: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}

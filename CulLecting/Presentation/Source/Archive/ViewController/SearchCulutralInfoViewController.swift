//
//  SearchCulutralInfoViewController.swift
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


final class SearchCulutralInfoViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: SearchCulturalInfoViewModel
    private weak var coordinator: ArchiveCoordinator?
    private let actionType: TicketActionType
    private let disposeBag = DisposeBag()
    private let selectedImageRelay = PublishRelay<UIImage>()
    
    private var searchResults: [CulturalImageEntity] = []
    private var lastSearchText: String = ""

    // MARK: UI Components
    private let searchBar = UISearchBar().then {
        $0.placeholder = "검색어를 입력해주세요"
        $0.searchBarStyle = .minimal
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .grey20
        $0.register(SearchedImageCell.self, forCellWithReuseIdentifier: SearchedImageCell.identifier)
    }
    
    // MARK: Init
    init(viewModel: SearchCulturalInfoViewModel, coordinator: ArchiveCoordinator, actionType: TicketActionType) {
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
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        setupUI()
    }
}
 
    // MARK: - Bindings
private extension SearchCulutralInfoViewController {
    
    func bindViewModel() {
        let input = SearchCulturalInfoViewModel.Input(
            searchTextTrigger: searchBar.rx.searchButtonClicked
                .withLatestFrom(searchBar.rx.text.orEmpty.asObservable()),
            selectImage: selectedImageRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.searchResults
            .drive(onNext: { [weak self] results in
                guard let self else { return }
                self.searchResults = results
                if results.isEmpty {
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
    }
}

// MARK: - Setup
private extension SearchCulutralInfoViewController {
    
    func setNavigationBar() {
        navigationItem.title = "이미지 검색"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(popViewController)
        ).then {
            $0.tintColor = .grey90
        }
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
extension SearchCulutralInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchedImageCell.identifier, for: indexPath) as? SearchedImageCell else {
            return UICollectionViewCell()
        }
        let culturalImage = searchResults[indexPath.item]
        cell.configure(with: culturalImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let culturalImage = searchResults[indexPath.item]
        
        if let url = URL(string: culturalImage.imageURL) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.selectedImageRelay.accept(value.image)
                    }
                case .failure(let error):
                    print("이미지 로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

//
//  SearchViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit
import Then
import SnapKit
import RxSwift

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: Properties
    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator
    private let disposeBag = DisposeBag()

    //MARK: init
    init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setNavigationBar()
        dataSetting()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "검색"
        navigationController?.navigationBar.tintColor = .primary50
    }

    //MARK: UI Components
    private let searchBar = UISearchBar().then {
        $0.placeholder = "내가 원하는 문화 컨텐츠를 검색하세요"
        $0.searchBarStyle = .minimal
        $0.searchTextField.backgroundColor = .clear
        $0.searchTextField.layer.cornerRadius = 15
        $0.searchTextField.layer.masksToBounds = true
        $0.searchTextField.font = .systemFont(ofSize: 16)
        $0.searchTextField.textAlignment = .left
        $0.searchTextField.clearButtonMode = .whileEditing
    }
    
    private let keywordLabel = UILabel().then {
        $0.text = "추천 검색어"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(SearchKeywordCell.self, forCellWithReuseIdentifier: SearchKeywordCell.identifier)
        collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
        return collectionView
    }()

    private let keywords = ["국악", "연극", "전시/미술", "클래식", "뮤지컬", "교육/체험", "전시회"]

    private var searchResults: [CulturalNameDTO] = []
    
    private lazy var filterStackView: UIView = {
        let container = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center // 세로 가운데 정렬
        stackView.spacing = 16
        stackView.distribution = .fill // 내용에 맞게 크기 조정
        
        let filterButton = UIButton(type: .system)
        filterButton.setImage(UIImage(named: "chip_filter"), for: .normal)
        filterButton.imageView?.contentMode = .scaleAspectFit
        filterButton.tintColor = .black
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        let dateButton = UIButton(type: .system)
        dateButton.setImage(UIImage(named: "chip_date"), for: .normal)
        dateButton.imageView?.contentMode = .scaleAspectFit
        dateButton.tintColor = .black
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        
        // 각 버튼의 크기를 자동으로 내용에 맞추기
        filterButton.setContentHuggingPriority(.required, for: .horizontal)
        dateButton.setContentHuggingPriority(.required, for: .horizontal)
        
        stackView.addArrangedSubview(filterButton)
        stackView.addArrangedSubview(dateButton)
        
        container.addSubview(stackView)
        
        // StackView를 왼쪽 정렬로 배치
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }()

    
    @objc
    private func filterButtonTapped() {
        print("필터 버튼 터치")
        let filterVC = FilterModalViewController(viewModel: viewModel, coordinator: coordinator)
        filterVC.modalPresentationStyle = .pageSheet
        present(filterVC, animated: true)
    }
    
    @objc
    private func dateButtonTapped() {
        print("날짜 버튼 터치")
        let dateVC = DateModalViewController(viewModel: viewModel, coordinator: coordinator)
        dateVC.modalPresentationStyle = .pageSheet
        present(dateVC, animated: true)
    }

    private var isSearching: Bool = false
    private var dataNotFound: Bool = false

    private func setupUI() {
        view.backgroundColor = .white
        
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        view.addSubview(keywordLabel)
        
        keywordLabel.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(filterStackView)
        filterStackView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(keywordLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func dataSetting() {
        viewModel.culturalSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] culturalList in
            if culturalList.isEmpty {
                self?.dataNotFound = true
                self?.searchResults = [CulturalNameDTO(id: -1, title: "", imageURL: "", place: "", startDate: "", endDate: "")]
            } else {
                self?.dataNotFound = false
                self?.searchResults = culturalList
            }
            self?.collectionView.reloadData()
        }).disposed(by: disposeBag)
    }

    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            dataNotFound = false
            searchResults = [] // 검색어가 비어있을 경우 결과 초기화
            collectionView.reloadData()
            return
        }
        
        // 검색어로 바로 검색 수행
        search(with: searchText)
    }

    // MARK: - UICollectionView DataSource, Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? searchResults.count : keywords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSearching {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
            if dataNotFound {
                cell.notDataConfigured()  // ✅ 데이터 없음 상태 표시
            } else {
                let result = searchResults[indexPath.item]
                cell.configure(imageUrl: result.imageURL, title: result.title, location: result.place, date: "\(result.startDate) ~ \(result.endDate)", id: result.id)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchKeywordCell.identifier, for: indexPath) as! SearchKeywordCell
            cell.configure(with: keywords[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearching {
            filterStackView.isHidden = false
            keywordLabel.isHidden = true
            collectionView.snp.makeConstraints {
                $0.top.equalTo(filterStackView.snp.bottom).offset(12)
            }
            return CGSize(width: collectionView.frame.width, height: 150)
        } else {
            filterStackView.isHidden = true
            keywordLabel.isHidden = false
            collectionView.snp.makeConstraints {
                $0.top.equalTo(keywordLabel.snp.bottom).offset(12)
            }

            // ✅ 추천 검색어 버튼 동적 너비 설정 (3개씩 균일하게)
            let totalWidth = collectionView.frame.width - 32 // 좌우 여백 (16 + 16)
            let spacing: CGFloat = 4 // 셀 간격
            let numberOfItemsPerRow: CGFloat = 4 // 한 줄에 3개
            
            // ✅ 동적 너비 계산
            let width = (totalWidth - (spacing * (numberOfItemsPerRow - 1))) / numberOfItemsPerRow
            return CGSize(width: width, height: 36)
        }
    }

    // ✅ 추천 검색어 클릭 시 검색 자동 실행
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSearching {
            let selectedKeyword = keywords[indexPath.item]
            searchBar.text = selectedKeyword
            search(with: selectedKeyword)
        } else {
            let selectedResult = searchResults[indexPath.item]
            if selectedResult.id != -1 {
                showDetail(for: selectedResult.id)
            }
        }
    }
    
    private func showDetail(for id: Int) {
        let detailVC = SearchDetailViewController(viewModel: viewModel, coordinator: coordinator, culturalId: id)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // ✅ 검색 로직 함수 추가
    private func search(with query: String) {
        // 검색어로 필터링된 결과를 searchResults에 반영
        isSearching = true
        viewModel.findDataFromKeyword(keyword: query)
        collectionView.reloadData()
    }
}

// MARK: - Custom Keyword Cell
class SearchKeywordCell: UICollectionViewCell {
    static let identifier = "SearchKeywordCell"

    private let keywordLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(keywordLabel)
        setupUI()
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
    }
    private func setupUI() {
        keywordLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(8)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-8)
            $0.top.equalTo(contentView.snp.top).offset(4)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-4)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        keywordLabel.text = text
    }
}

// MARK: - Custom UICollectionViewCell for Search Results
class SearchResultCell: UICollectionViewCell {
    static let identifier = "SearchResultCell"
    
    private var culturalId: Int?
    
    private let imageView = UIImageView().then {
        $0.contentMode = UIView.ContentMode.scaleAspectFit
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.lineBreakMode = .byTruncatingTail
    }
    private let locationLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.lineBreakMode = .byTruncatingTail
    }
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.lineBreakMode = .byTruncatingTail
    }
    let textStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    let mainStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
    }

    private let failLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .gray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(locationLabel)
        textStack.addArrangedSubview(dateLabel)
        
        contentView.addSubview(mainStack)
        mainStack.addArrangedSubview(imageView)
        mainStack.addArrangedSubview(textStack)
        
        mainStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
        }

        // ✅ 이미지 크기 고정 (4:3 비율)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(120)
        }

        // ✅ 텍스트 스택이 이미지 오른쪽에서 가득 차도록 설정
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalTo(mainStack.snp.trailing)
            make.top.equalTo(mainStack.snp.top)
            make.bottom.lessThanOrEqualTo(mainStack.snp.bottom)
        }
        contentView.addSubview(failLabel)
        failLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalToSuperview()
        }
    }
    
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // URLSession을 사용한 비동기 이미지 로드
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("이미지 로드 실패:", error.localizedDescription)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("이미지 변환 실패")
                return
            }
            
            // UI 업데이트는 메인 스레드에서 수행해야 함
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
    
    func configure(imageUrl: String, title: String, location: String, date: String, id: Int) {
        failLabel.isHidden = true
        mainStack.isHidden = false
        textStack.isHidden = false
        imageView.isHidden = false
        if imageUrl == "", title == "", location == "", date == "" {
            notDataConfigured()
        } else {
            loadImageFromURL(imageUrl)
            titleLabel.text = title
            locationLabel.text = location
            dateLabel.text = date
            culturalId = id
        }
    }
    
    func notDataConfigured() {
        failLabel.text = "데이터를 찾을 수 없습니다."
        failLabel.isHidden = false
        mainStack.isHidden = true
        textStack.isHidden = true
        imageView.isHidden = true
    }
}

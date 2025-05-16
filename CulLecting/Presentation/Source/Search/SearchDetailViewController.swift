//
//  SearchDetailViewController.swift
//  CulLecting
//
//  Created by SeungHwanMacBook on 5/9/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import MapKit
import SafariServices

class SearchDetailViewController: UIViewController {
    
    private let viewModel: SearchViewModel
    private let coordinator: SearchCoordinator
    private let disposeBag = DisposeBag()
    
    private let culturalId: Int
    
    private var pendingLatitude: Double?
    private var pendingLongitude: Double?
    
    private var homePageURL: String?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // ✅ viewDidLayoutSubviews에서 지도 설정 (안전하게)
        if let latitude = pendingLatitude, let longitude = pendingLongitude {
            setMapRegion(latitude: latitude, longitude: longitude)
            pendingLatitude = nil
            pendingLongitude = nil
        }
    }
    
    init(viewModel: SearchViewModel, coordinator: SearchCoordinator, culturalId: Int) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.culturalId = culturalId
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        viewModel.findDetailData(id: culturalId)
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.numberOfLines = 0
    }

    private let categoryLabel = UILabel().then {
        $0.textColor = UIColor.orange
        $0.font = .systemFont(ofSize: 14, weight: .bold)
        $0.backgroundColor = .grey30
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
    }
    
    private let imageStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .white
    }

    private let eventImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    let textStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    
    private let placeLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.lineBreakMode = .byTruncatingTail
        $0.numberOfLines = 0
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.lineBreakMode = .byTruncatingTail
        $0.numberOfLines = 0
    }
    
    private let targetAndCostLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
        $0.lineBreakMode = .byTruncatingTail
        $0.numberOfLines = 0
    }
    
    private let buttonContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }
    
    private static func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system).then {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.contentHorizontalAlignment = .left
            $0.titleLabel?.font = .systemFont(ofSize: 16)
            $0.backgroundColor = .white
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
        // ✅ 오른쪽 화살표 이미지 추가
        let arrowIcon = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowIcon.tintColor = .gray
        button.addSubview(arrowIcon)
        arrowIcon.snp.makeConstraints {
            $0.centerY.equalTo(button)
            $0.trailing.equalTo(button).offset(-16)
        }
        
        return button
    }
    
    private let homepageButton = createButton(title: "홈페이지 바로가기")
    
    private let addressContainer = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    private let addressStackVIew = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }
    
    private let addressDataLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal) // ✅ 남은 공간을 차지
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private let addressLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.numberOfLines = 0
        $0.text = "주소"
        $0.setContentHuggingPriority(.required, for: .horizontal) // ✅ 고정된 너비 우선순위
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let mapView = MKMapView()

    private func setupData() {
        viewModel.culturalDetailSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] cultural in
            self?.categoryLabel.text = cultural.codename
            self?.titleLabel.text = cultural.title
            self?.loadImageFromURL(cultural.mainImg)
            self?.addressDataLabel.text = cultural.place
            self?.placeLabel.text = "장소 \(cultural.place)"
            self?.dateLabel.text = "기간 \(cultural.date)"
            self?.homePageURL = cultural.orgLink
            let isFree = cultural.free ? "무료" : "유료"
            if cultural.themeCode == "기타" {
                self?.targetAndCostLabel.text = "전체 ∘ \(isFree)"
            } else {
                self?.targetAndCostLabel.text = "\(cultural.themeCode) ∘ \(isFree)"
            }
            if let latitude = Double(cultural.lot),
               let longitude = Double(cultural.lat) {
                self?.pendingLatitude = latitude
                self?.pendingLongitude = longitude
            } else {
                print("좌표 변환 실패: 유효한 좌표가 아닙니다.")
            }
            
        })
        .disposed(by: disposeBag)
    }

    private func setupUI() {
        view.backgroundColor = .grey10
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view.snp.width)
        }
        
        textStack.addArrangedSubview(placeLabel)
        textStack.addArrangedSubview(dateLabel)
        textStack.addArrangedSubview(targetAndCostLabel)
        
        imageStackView.addArrangedSubview(eventImageView)
        imageStackView.addArrangedSubview(textStack)
        
        buttonContainer.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        buttonStackView.addArrangedSubview(homepageButton)
        
        homepageButton.addTarget(self, action: #selector(openHomePage), for: .touchUpInside)
        
        addressStackVIew.addArrangedSubview(addressLabel)
        addressStackVIew.addArrangedSubview(addressDataLabel)
        addressContainer.addSubview(addressStackVIew)
        addressContainer.addSubview(mapView)

        contentView.addSubview(categoryLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageStackView)
        contentView.addSubview(buttonContainer)
        contentView.addSubview(addressContainer)
        

        categoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(30)
            $0.width.equalTo(80)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        imageStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(160)
        }
        
        eventImageView.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(160)
        }
        
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(eventImageView.snp.trailing).offset(12)
                make.trailing.equalTo(imageStackView.snp.trailing)
                make.top.equalTo(imageStackView.snp.top)
                make.bottom.lessThanOrEqualTo(imageStackView.snp.bottom)
        }
        
        buttonContainer.snp.makeConstraints {
            $0.top.equalTo(eventImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        homepageButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
        }
        
        addressContainer.snp.makeConstraints {
            $0.top.equalTo(buttonContainer.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(250)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        addressStackVIew.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        mapView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
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
                self.eventImageView.image = image
            }
        }.resume()
    }
    
    // ✅ 지도 이동 및 마커 추가 함수
    private func setMapRegion(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // ✅ 좌표값 유효성 검사
        guard latitude >= -90, latitude <= 90, longitude >= -180, longitude <= 180 else {
            print("❌ 유효하지 않은 좌표: \(latitude), \(longitude)")
            return
        }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // ✅ 마커 추가
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "여기입니다!"
        mapView.addAnnotation(annotation)
        
        getAddressFromCoordinates(latitude: latitude, longitude: longitude)
    }
    
    // ✅ 역 지오코딩 함수
    private func getAddressFromCoordinates(latitude: Double, longitude: Double) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("❌ 주소 변환 오류:", error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("❌ 주소를 찾을 수 없습니다.")
                return
            }
            
            var addressString = ""
            
            // ✅ 주소 구성 (도로명, 시/군/구, 행정구역)
            if let locality = placemark.locality {
                addressString += locality + " "
            }
            if let thoroughfare = placemark.thoroughfare {
                addressString += thoroughfare + " "
            }
            if let subThoroughfare = placemark.subThoroughfare {
                addressString += subThoroughfare + " "
            }
            
            print("✅ 주소:", addressString.trimmingCharacters(in: .whitespaces))
            
            // ✅ UI 업데이트 (메인 스레드에서)
            DispatchQueue.main.async {
                self?.addressDataLabel.text = addressString.trimmingCharacters(in: .whitespaces)
            }
        }
    }
    
    @objc
    private func openHomePage() {
        guard let url = homePageURL else { return }
        openSafariViewController(with: url)
    }
    
    private func openSafariViewController(with urlString: String) {
        if let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.modalPresentationStyle = .overFullScreen
            present(safariVC, animated: true, completion: nil)
        }
    }
}

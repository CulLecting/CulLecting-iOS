//
//  AddTicketViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/23/25.
//


import UIKit


import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then

final class AddTicketViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: AddTicketViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    private let imageView = UIImageView().then {
        $0.backgroundColor = .grey10
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    private let photoButton = UIButton().then {
        $0.setTitle("사진 추가", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .grey90
        $0.layer.cornerRadius = 8
    }

    private let titleField = UITextField().then {
        $0.placeholder = "제목 입력"
        $0.borderStyle = .roundedRect
    }

    private let descriptionView = UITextView().then {
        $0.font = .systemFont(ofSize: 14)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.grey30.cgColor
        $0.layer.cornerRadius = 8
    }

    private let datePicker = UIDatePicker().then {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
    }

    private let categoryField = UITextField().then {
        $0.placeholder = "카테고리 입력"
        $0.borderStyle = .roundedRect
    }

    private let templateField = UITextField().then {
        $0.placeholder = "템플릿 -> uipickerview로 변경"
        $0.borderStyle = .roundedRect
        $0.isUserInteractionEnabled = false
    }

    private let uploadButton = UIButton().then {
        $0.setTitle("업로드", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .primary50
        $0.layer.cornerRadius = 10
    }

    // MARK: - Init
    init(viewModel: AddTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootContainer.pin.all(view.pin.safeArea)
        rootContainer.flex.layout()
    }

    // MARK: - Bind
    private func bindViewModel() {
        let imageRelay = BehaviorRelay<UIImage?>(value: nil)

        photoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self?.present(picker, animated: true)
            })
            .disposed(by: disposeBag)

        let input = AddTicketViewModel.Input(
            image: imageRelay.asObservable(),
            title: titleField.rx.text.orEmpty.asObservable(),
            description: descriptionView.rx.text.orEmpty.asObservable(),
            date: datePicker.rx.date.asObservable(),
            category: categoryField.rx.text.orEmpty.asObservable(),
            template: templateField.rx.text.orEmpty.asObservable(),
            uploadTap: uploadButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.uploadResult
            .emit(onNext: { [weak self] success in
                guard let self else { return }
                if success {
                    self.showAlert(title: "완료", message: "업로드 성공") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showAlert(title: "실패", message: "업로드에 실패했어요.")
                }
            })
            .disposed(by: disposeBag)

        output.isUploading
            .drive(uploadButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // 이미지 바인딩
        imageRelay
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)

        // 내부에서 사용할 수 있게 저장
        self.imageRelay = imageRelay
    }

    // MARK: - UI
    private let rootContainer = UIView()
    private var imageRelay = BehaviorRelay<UIImage?>(value: nil)

    private func setUI() {
        view.addSubview(rootContainer)

        rootContainer.flex.padding(20).define {
            $0.addItem(imageView).height(200).marginBottom(12)
            $0.addItem(photoButton).height(44).marginBottom(16)
            $0.addItem(titleField).height(44).marginBottom(12)
            $0.addItem(descriptionView).height(100).marginBottom(12)
            $0.addItem(datePicker).height(44).marginBottom(12)
            $0.addItem(categoryField).height(44).marginBottom(12)
            $0.addItem(templateField).height(44).marginBottom(20)
            $0.addItem(uploadButton).height(50)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddTicketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageRelay.accept(image)
        }
        picker.dismiss(animated: true)
    }
}

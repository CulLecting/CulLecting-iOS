//
//  PhotoPreviewViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

import RxCocoa
import RxSwift


final class PhotoPreviewViewController: UIViewController {
    
    private let image: UIImage
    private let onConfirm: (UIImage) -> Void
    private let disposeBag = DisposeBag()
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    init(image: UIImage, onConfirm: @escaping (UIImage) -> Void) {
        self.image = image
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.pin.all()
    }
    
    private func setupNavigation() {
        navigationItem.title = "사진 업로드"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "확인",
            style: .done,
            target: self,
            action: #selector(confirmButtonTapped)
        )
    }
    
    @objc private func confirmButtonTapped() {
        onConfirm(image)
    }
}

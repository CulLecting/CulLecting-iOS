//
//  MyPageViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import SafariServices
import UIKit

import FlexLayout
import PinLayout
import RxCocoa
import RxSwift
import Then


public class MypageViewController: UIViewController {
    //MARK: Properties
    private let viewModel: MypageViewModel
    private let coordinator: MypageCoordinator
    private let disposeBag = DisposeBag()
    
    private let logoutTrigger = PublishRelay<Void>()
    private let deleteTrigger = PublishRelay<Void>()
    
    //MARK: UI Components
    private let userName = UILabel().then {
        $0.text = "Guest 님"
        $0.font = .fontPretendard(style: .title18SB)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byClipping
    }
    private let editLabel = UILabel().then {
        $0.text = "내 정보 수정"
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey70
    }
    private let chevronImg = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.tintColor = .grey90
        $0.contentMode = .scaleAspectFit
    }
    
    private let myInfoEditView = UIView()
    
    private let MypageMenuTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MypageMenuTableViewCell.self, forCellReuseIdentifier: MypageMenuTableViewCell.mypageMenuTableViewCellIdentifier)
    }
    
    private let logoutButton = UIButton.makeTextButton(title: "로그아웃", titleColor: .grey80, font: .fontPretendard(style: .body13M), underline: .underlineTrue)
    
    private let exitButton = UIButton.makeTextButton(title: "회원탈퇴", titleColor: .grey80, font: .fontPretendard(style: .body13M), underline: .underlineTrue)
    
    //MARK: init
    init(viewModel: MypageViewModel, coordinator: MypageCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        setupTableView()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Lifecycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grey10
        setUI()
        setupBinding()
        //setGesture()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.pin.all(view.pin.safeArea)
        container.flex.layout()
    }
    
    //MARK: 기타 메서드
    //TODO: 페이지 미구현
    //    private func setGesture() {
    //        let tapMyInfoEditGesture = UITapGestureRecognizer(target: self, action: #selector(moveToEditInfoVC))
    //        myInfoEditView.addGestureRecognizer(tapMyInfoEditGesture)
    //        myInfoEditView.isUserInteractionEnabled = true
    //    }
    
    @objc private func moveToEditInfoVC() {
        let editVC = EditInfoViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    //MARK: UI
    private let container = UIView()
    private let myInfoView = UIView()
    
    private func setUI() {
        view.addSubview(container)
        
        container.flex
            .direction(.column)
            .marginHorizontal(20)
            .define {
                $0.addItem(myInfoEditView)
                    .padding(10, 10)
                    .marginTop(30)
                    .marginBottom(40)
                $0.addItem(MypageMenuTableView)
                    .grow(1)
                $0.addItem()
                    .direction(.row)
                    .marginBottom(20)
                    .justifyContent(.center)
                    .define {
                        $0.addItem(logoutButton)
                            .width(150).height(44)
                            .marginRight(24)
                        
                        $0.addItem(exitButton)
                            .width(150).height(44)
                    }
            }
        
        myInfoEditView.flex
            .direction(.row)
            .alignItems(.center)
            .define {
                $0.addItem(myInfoView)
                //                    .grow(1)
                //                $0.addItem(chevronImg)
                //                    .width(20)
                //                    .height(20)
                //                    .marginRight(20)
            }
        
        myInfoView.flex
            .direction(.column)
            .width(100%)
            .height(30)
            .define {
                $0.addItem(userName)
                //                $0.addItem(editLabel)
            }
    }
}

// 바인딩 관련
extension MypageViewController {
    private func setupBinding() {
        print("SetupBinding 호출됨")

        let input = MypageViewModel.Input(
            logoutTrigger: logoutTrigger.asObservable(),
            deleteTrigger: deleteTrigger.asObservable()
        )

        let output = viewModel.transform(input: input)

        // Handle login state from ViewModel
        output.isLoggedIn
            .drive(onNext: { [weak self] isLoggedIn in
                guard let self = self else { return }
                if !isLoggedIn {
                    self.userName.text = "Guest 님"
                    self.logoutButton.isHidden = true
                    self.exitButton.isHidden = true
                } else {
                    self.logoutButton.isHidden = false
                    self.exitButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlertWithCancel(
                    title: "로그아웃",
                    message: "로그아웃 하시겠습니까?",
                    okTitle: "확인",
                    cancelTitle: "취소",
                    okHandler: {
                        self?.logoutTrigger.accept(())
                    }
                )
            })
            .disposed(by: disposeBag)

        exitButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlertWithCancel(
                    title: "정말 탈퇴하시겠습니까?",
                    message: "탈퇴가 완료되면 모든 정보가 삭제되며, 복구할 수 없습니다.",
                    okTitle: "탈퇴하기",
                    cancelTitle: "취소",
                    okHandler: {
                        self?.deleteTrigger.accept(())
                    }
                )
            })
            .disposed(by: disposeBag)

        output.nickname
            .drive(onNext: { [weak self] nickname in
                self?.userName.text = "\(nickname) 님"
            })
            .disposed(by: disposeBag)

        output.logoutCompleted
            .emit(onNext: { [weak self] in
                self?.coordinator.didLogout()
            })
            .disposed(by: disposeBag)

        output.deleteCompleted
            .emit(onNext: { [weak self] in
                self?.showAlert(
                    title: "탈퇴 완료",
                    message: "정상적으로 탈퇴되었습니다."
                ) {
                    self?.coordinator.didLogout()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MypageViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        MypageMenuTableView.delegate = self
        MypageMenuTableView.dataSource = self
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MypageMenu.allMenus.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MypageMenuTableViewCell.mypageMenuTableViewCellIdentifier) as? MypageMenuTableViewCell else {
            return UITableViewCell()
        }
        let menuItem = MypageMenu.allMenus[indexPath.row]
        cell.configure(menuItem: menuItem)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = MypageMenu.allMenus[indexPath.row]
        let safariVC = SFSafariViewController(url: menuItem.url)
        present(safariVC, animated: true)
    }
}

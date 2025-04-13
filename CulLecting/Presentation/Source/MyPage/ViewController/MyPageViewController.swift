//
//  MyPageViewController.swift
//  CulLecting
//
//  Created by 김승희 on 4/7/25.
//


import UIKit

import FlexLayout
import PinLayout
import Then


public class MyPageViewController: UIViewController {

    private let userName = UILabel().then {
        $0.text = "컬렉팅님" //네트워크 연결시 수정필요
        $0.font = .fontPretendard(style: .title18SB)
        $0.textColor = .grey90
    }
    private let editLabel = UILabel().then {
        $0.text = "내 정보 수정"
        $0.font = .fontPretendard(style: .body14M)
        $0.textColor = .grey70
    }
    private let chevronImg = UIImageView(image: UIImage(systemName: "chevron.right")).then {
        $0.tintColor = .grey90
    }
    
    private let MypageMenuTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MypageMenuTableViewCell.self, forCellReuseIdentifier: MypageMenuTableViewCell.mypageMenuTableViewCellIdentifier)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grey20
        setUI()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.pin.all(view.pin.safeArea)
        container.flex.layout()
    }
    
    //MARK: 기타 메서드

    
    //MARK: UI
    private let container = UIView()
    private let myInfoView = UIView()
    private let myInfoEditView = UIView()
    
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
            }
        
        myInfoEditView.flex
            .direction(.row)
            .alignItems(.center)
            .define {
                $0.addItem(myInfoView)
                    .grow(1)
                $0.addItem(chevronImg)
                    .width(20)
                    .height(20)
                    .marginRight(20)
            }
        
        myInfoView.flex
            .direction(.column)
            .define {
                $0.addItem(userName)
                    .marginTop(10)
                $0.addItem(editLabel)
            }
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
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
}

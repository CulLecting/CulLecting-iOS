//
//  MypageMenuEntity.swift
//  CulLecting
//
//  Created by 김승희 on 4/14/25.
//


import UIKit


struct MypageMenu {
    let icon: UIImage
    let title: String
}

extension MypageMenu {
    static let allMenus: [MypageMenu] = [
        MypageMenu(icon: UIImage.mypageAnnouncement, title: "공지사항"),
        MypageMenu(icon: UIImage.mypageFaq, title: "자주 묻는 질문"),
        MypageMenu(icon: UIImage.mypagePolicy, title: "약관 및 정책")
    ]
}

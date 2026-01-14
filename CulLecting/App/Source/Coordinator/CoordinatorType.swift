//
//  CoordinatorType.swift
//  CulLecting
//
//  Created by 김승희 on 4/27/25.
//


import UIKit


//public enum CoordinatorType {
//    case app, login, onboarding, tabbar //ParentFlow
//    case home, archive, search, mypage //TabbarFlow
//}
//

enum TabItem: Int, CaseIterable {
    case home
    case archive
    case search
    case mypage

    var title: String {
        switch self {
        case .home: return "홈"
        case .archive: return "아카이브"
        case .search: return "검색"
        case .mypage: return "마이페이지"
        }
    }

    var icon: UIImage? {
        switch self {
        case .home: return UIImage.tabbarHome
        case .archive: return UIImage.tabbarArchive
        case .search: return UIImage.tabbarSearch
        case .mypage: return UIImage.tabbarMyPage
        }
    }
}

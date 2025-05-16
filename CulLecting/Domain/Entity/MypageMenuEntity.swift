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
    let url: URL
}

extension MypageMenu {
    static let allMenus: [MypageMenu] = [
        MypageMenu(icon: UIImage.mypagePolicy,
                   title: "개인정보 처리방침",
                   url: URL(string: "https://sore-harp-335.notion.site/1ea2df26223f8082a16bdd17dc0ba008?pvs=4")!),
        
        MypageMenu(icon: UIImage.mypageService,
                   title: "서비스 이용약관",
                   url: URL(string: "https://sore-harp-335.notion.site/Cul-Lecting-1ea2df26223f8034b53ce444fc39ae89?pvs=4")!),
        
        MypageMenu(icon: UIImage.mypageReport,
                   title: "고객문의 및 버그 리포트",
                   url: URL(string: "https://forms.gle/s3TC9wdq7WcEvUgn8")!)
    ]
}

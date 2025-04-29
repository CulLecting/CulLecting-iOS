//
//  UIViewController+AddMenu.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

extension UIViewController {
    func presentAddMenu(onSearch: @escaping () -> Void, onPick: @escaping () -> Void) {
        let alert = UIAlertController(title: "티켓 추가하기", message: nil, preferredStyle: .actionSheet)
        let searchAction = UIAlertAction(title: "검색하기", style: .default) { _ in
            onSearch()
        }
        let uploadAction = UIAlertAction(title: "보관함에서 선택", style: .default) { _ in
            onPick()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        [searchAction, uploadAction, cancelAction].forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
}

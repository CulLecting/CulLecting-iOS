//
//  UIViewController+AddMenu.swift
//  CulLecting
//
//  Created by 김승희 on 4/28/25.
//


import UIKit

extension UIViewController {
    func presentAddMenu(
        onSearch: @escaping () -> Void,
        onPick: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: "티켓 \(onDelete == nil ? "추가하기" : "관리하기")", message: nil, preferredStyle: .actionSheet)
        
        let searchAction = UIAlertAction(title: "검색하기", style: .default) { _ in onSearch() }
        let uploadAction = UIAlertAction(title: "보관함에서 선택", style: .default) { _ in onPick() }
        alert.addAction(searchAction)
        alert.addAction(uploadAction)
        
        if let onDelete = onDelete {
            let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in onDelete() }
            alert.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

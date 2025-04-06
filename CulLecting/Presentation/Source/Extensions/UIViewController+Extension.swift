//
//  UIViewController+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/4/25.
//

import UIKit
import FlexLayout
import PinLayout

extension UIViewController {
    
    /// toast 표시 메서드
    /// message: 표시할 메시지
    /// iconStyle: 메시지 왼쪽의 아이콘 선택
    /// duration: 메시지가 화면에 남는 시간
    func showToast(message: String, iconStyle: toastIconStyle, duration: TimeInterval) {
        let toastView = CustomToastView(message: message, iconStyle: iconStyle)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        var toastWindow = UIWindow(windowScene: windowScene)
        toastWindow.backgroundColor = .clear
        toastWindow.windowLevel = .alert
        toastWindow.isUserInteractionEnabled = false
        toastWindow.isHidden = false
        print("window 개수: \(windowScene.windows.count)개")
        
        toastWindow.addSubview(toastView)
        toastWindow.layoutIfNeeded()
        
        //MARK: 이거 메모리 해제 테스트 해보기
        toastView.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            toastView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
                toastWindow.isHidden = true
                toastWindow.windowScene = nil
            })
        }
    }
}

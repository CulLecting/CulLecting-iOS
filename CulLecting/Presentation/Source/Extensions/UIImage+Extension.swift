//
//  UIImage+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/10/25.
//

import UIKit

extension UIImage {
    /// 자유 크기 리사이즈 메서드
    ///     - newsize: CGSize
    func resize(newSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resizedImage
    }
    
    /// 기존 이미지 종횡비 유지하는 리사이즈 메서드
    func resizePreservingRatio(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        print("UIScreen scale: \(UIScreen.main.scale)")
        print("원본 이미지: \(self), 리사이즈 이미지: \(resizedImage)")
        // printDataSize(resizedImage) // 데이터 크기 출력 함수
        return resizedImage
    }
    
    /// 일정한 비율로 리사이즈하는 메서드
    /// 고정된 비율에 따른 height 계산 (예: 4:3이면 newHeight = newWidth * (3/4))
    func resizeFixedRatio(newWidth: CGFloat, aspectRatio: Float) -> UIImage {
        let newHeight = newWidth * CGFloat(aspectRatio)
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

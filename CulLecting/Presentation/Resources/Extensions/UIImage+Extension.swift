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
    
    /// 이미지 평균 색상값 계산 메서드
    func averageColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extent = inputImage.extent
        let extentVector = CIVector(x: extent.origin.x,
                                    y: extent.origin.y,
                                    z: extent.size.width,
                                    w: extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [
                                        kCIInputImageKey: inputImage,
                                        kCIInputExtentKey: extentVector
                                    ]) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        
        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: 1.0
        )
    }
}

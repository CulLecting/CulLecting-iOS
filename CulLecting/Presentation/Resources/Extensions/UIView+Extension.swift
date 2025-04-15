//
//  UIView+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/15/25.
//


import UIKit


extension UIView {
    func snapshotImage() -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale
        
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}

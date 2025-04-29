//
//  UIImagePickerController+Extension.swift
//  CulLecting
//
//  Created by 김승희 on 4/29/25.
//


import UIKit
import ObjectiveC


private var imagePickerCompletionKey: UInt8 = 0

extension UIImagePickerController: @retroactive UINavigationControllerDelegate, @retroactive UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            completionHandler?(image)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    var completionHandler: ((UIImage) -> Void)? {
        get {
            return objc_getAssociatedObject(self, &imagePickerCompletionKey) as? (UIImage) -> Void
        }
        set {
            objc_setAssociatedObject(self, &imagePickerCompletionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

//
//  Extension+UIImage.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import Foundation
import UIKit

extension UIImage {

    func resized(to maxDimension: CGFloat) -> UIImage? {
        let aspectRatio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

//
//  UIView+parentViewController.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

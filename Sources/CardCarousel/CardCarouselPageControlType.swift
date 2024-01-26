//
//  CardCarouselPageControlType.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

public protocol CardCarouselPageControlType: UIView {
    var numberOfPages: Int { get set }
    
    var currentPage: Int { get }
}

public protocol CardCarouselNormalPageControlType: CardCarouselPageControlType {
    var currentPage: Int { get set }
}

public protocol CardCarouselContinousPageControlType: CardCarouselPageControlType {
    var progress: Double { get set }
}

extension UIPageControl: CardCarouselNormalPageControlType { }

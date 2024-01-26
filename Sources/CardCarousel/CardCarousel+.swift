//
//  CardCarousel+.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

public struct CardLayoutDimension {
    enum Options {
        case fractionalWidth(CGFloat, inset: CGFloat)
        case fractionalHeight(CGFloat, inset: CGFloat)
        case absolute(CGFloat)
    }
    
    var options: Options
    
    init(options: Options) {
        self.options = options
    }
    
    public static func fractionalWidth(_ fractionalWidth: CGFloat, inset: CGFloat = 0) -> CardLayoutDimension {
        CardLayoutDimension(options: .fractionalWidth(fractionalWidth, inset: inset))
    }

    public static func fractionalHeight(_ fractionalHeight: CGFloat, inset: CGFloat = 0) -> CardLayoutDimension {
        CardLayoutDimension(options: .fractionalHeight(fractionalHeight, inset: inset))
    }

    public static func absolute(_ absoluteDimension: CGFloat) -> CardLayoutDimension {
        CardLayoutDimension(options: .absolute(absoluteDimension))
    }
}

public struct CardLayoutSize {
    public var widthDimension: CardLayoutDimension
    public var heightDimension: CardLayoutDimension
    
    public init(widthDimension: CardLayoutDimension = .fractionalWidth(1), heightDimension: CardLayoutDimension = .fractionalHeight(1)) {
        self.widthDimension = widthDimension
        self.heightDimension = heightDimension
    }
    
    func actualValue(withContainerSize size: CGSize) -> CGSize {
        var width: CGFloat
        var height: CGFloat
        
        switch widthDimension.options {
        case let .fractionalWidth(ratio, inset):
            width = (size.width - 2 * inset) * ratio
        case let .fractionalHeight(ratio, inset):
            width = (size.height - 2 * inset) * ratio
        case let .absolute(value):
            width = value
        }
        
        switch heightDimension.options {
        case let .fractionalWidth(ratio, inset):
            height = (size.width - 2 * inset) * ratio
        case let .fractionalHeight(ratio, inset):
            height = (size.height - 2 * inset) * ratio
        case let .absolute(value):
            height = value
        }
        
        return CGSize(width: width, height: height)
    }
}

public struct CardScrollStopAlignment {
    enum Options {
        case center(offset: CGFloat)
        /// head 即滚动开始的位置
        case head(offset: CGFloat)
    }
    
    var options: Options
    
    init(options: Options) {
        self.options = options
    }
    
    public static let center = CardScrollStopAlignment(options: .center(offset: 0))
    
    public static func center(offset: CGFloat) -> CardScrollStopAlignment {
        .init(options: .center(offset: offset))
    }
    
    public static let head = CardScrollStopAlignment(options: .head(offset: 0))
    
    public static func head(offset: CGFloat) -> CardScrollStopAlignment {
        .init(options: .head(offset: offset))
    }
}

public enum CardScrollDirection: Int {
    case leftToRight = 1
    case rightToLeft = 2
    case topToBottom = 3
    case bottomToTop = 4
}

public struct CardTransformMode {
    enum Options {
        case none
        case liner(rateOfChange: CGFloat, minimumScale: CGFloat, minimumAlpha: CGFloat)
        case coverflow(rateOfChange: CGFloat, maximumAngle: CGFloat, minimumAlpha: CGFloat)
        case custom((_ attributes: UICollectionViewLayoutAttributes, _ visibleRect: CGRect) -> Void)
    }
    
    var options: Options
    
    init(options: Options) {
        self.options = options
    }
    
    public static let none = CardTransformMode(options: .none)
    
    public static let liner = CardTransformMode(options: .liner(rateOfChange: 0.5, minimumScale: 0.8, minimumAlpha: 1))
    
    public static func liner(rateOfChange: CGFloat = 0.5, minimumScale: CGFloat = 0.8, minimumAlpha: CGFloat = 1) -> CardTransformMode {
        .init(options: .liner(rateOfChange: rateOfChange, minimumScale: minimumScale, minimumAlpha: minimumAlpha))
    }
    
    public static let coverflow = CardTransformMode(options: .coverflow(rateOfChange: 0.5, maximumAngle: 0.2, minimumAlpha: 1))
    
    public static func coverflow(rateOfChange: CGFloat = 0.5, maximumAngle: CGFloat = 0.2, minimumAlpha: CGFloat = 1) -> CardTransformMode {
        .init(options: .coverflow(rateOfChange: rateOfChange, maximumAngle: maximumAngle, minimumAlpha: minimumAlpha))
    }
    
    public static func custom(_ transform: @escaping (_ attributes: UICollectionViewLayoutAttributes, _ visibleRect: CGRect) -> Void) -> CardTransformMode {
        .init(options: .custom(transform))
    }
}

public struct PageControlPosition {
    enum Options {
        case leftTop
        case rightTop
        case leftBottom
        case rightBottom
        case centerXTop
        case centerXBottom
        case leftCenterY
        case rightCenterY
    }
    
    var options: Options
    
    var offset: CGPoint
    
    init(options: Options, offset: CGPoint) {
        self.options = options
        self.offset = offset
    }
    
    public static let leftTop = PageControlPosition(options: .leftTop, offset: .zero)
    
    public static func leftTop(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .leftTop, offset: offset)
    }
    
    public static let rightTop = PageControlPosition(options: .rightTop, offset: .zero)
    
    public static func rightTop(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .rightTop, offset: offset)
    }
    
    public static let leftBottom = PageControlPosition(options: .leftBottom, offset: .zero)
    
    public static func leftBottom(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .leftBottom, offset: offset)
    }
    
    public static let rightBottom = PageControlPosition(options: .rightBottom, offset: .zero)
    
    public static func rightBottom(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .rightBottom, offset: offset)
    }
    
    public static let centerXTop = PageControlPosition(options: .centerXTop, offset: .zero)
    
    public static func centerXTop(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .centerXTop, offset: offset)
    }
    
    public static let centerXBottom = PageControlPosition(options: .centerXBottom, offset: .zero)
    
    public static func centerXBottom(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .centerXBottom, offset: offset)
    }
    
    public static let leftCenterY = PageControlPosition(options: .leftCenterY, offset: .zero)
    
    public static func leftCenterY(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .leftCenterY, offset: offset)
    }
    
    public static let rightCenterY = PageControlPosition(options: .rightCenterY, offset: .zero)
    
    public static func rightCenterY(offset: CGPoint) -> PageControlPosition {
        PageControlPosition(options: .rightCenterY, offset: offset)
    }
}

public enum CardLoopMode {
    case circular   // 环形循环
    case rollback   // 快速回滚
    case single     // 滚动到最后就停止
}

public enum CardScrollMode {
    case automatic(timeInterval: TimeInterval)
    case manual
}

public enum CardPagingThreshold {
    case fractional(CGFloat)
    case absolute(CGFloat)
}

enum SlideDirection {
    case forward
    case backward
}

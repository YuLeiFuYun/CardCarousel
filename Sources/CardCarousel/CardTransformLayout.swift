//
//  CardTransformLayout.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

final class CardTransformLayout: UICollectionViewFlowLayout {
    
    private var cardScrollDirection: CardScrollDirection
    
    var cardScrollStopAlignment: CardScrollStopAlignment = .center
    
    var cardTransformMode: CardTransformMode = .none
    
    var disableCurrentCardAlwaysOnTop: Bool = false
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        cardScrollDirection == .rightToLeft
    }
    
    init(cardScrollDirection: CardScrollDirection = .leftToRight) {
        self.cardScrollDirection = cardScrollDirection
        super.init()
        
        self.minimumLineSpacing = 0
        self.scrollDirection = .horizontal
        switch cardScrollDirection {
        case .rightToLeft, .leftToRight:
            self.scrollDirection = .horizontal
        case .bottomToTop, .topToBottom:
            self.scrollDirection = .vertical
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardTransformLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if case .none = cardTransformMode.options {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        } else {
            return true
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if case .none = cardTransformMode.options { return super.layoutAttributesForElements(in: rect) }
        
        let attributesArray = NSArray(array: super.layoutAttributesForElements(in: rect)!, copyItems: true) as! [UICollectionViewLayoutAttributes]
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        for attributes in attributesArray {
            guard CGRectIntersectsRect(visibleRect, attributes.frame) else { continue }
            
            switch cardTransformMode.options {
            case .liner:
                applyLinearTransform(to: attributes)
            case .coverflow:
                applyCoverflowTransform(to: attributes)
            case let .custom(transform):
                transform(attributes, visibleRect)
            default:
                break
            }
        }
        
        return attributesArray
    }
}

fileprivate extension CardTransformLayout {
    func applyLinearTransform(to attributes: UICollectionViewLayoutAttributes) {
        guard case let .liner(rateOfChange, minimumScale, minimumAlpha) = cardTransformMode.options else {
            return
        }
        
        let collectionViewSize = collectionView!.bounds.size
        let distance = caculateDistance(with: attributes)
        var scale: CGFloat, alpha: CGFloat
        switch cardScrollDirection {
        case .rightToLeft, .leftToRight:
            scale = max(1 - abs(distance) / collectionViewSize.width * rateOfChange, minimumScale)
            alpha = max(1 - abs(distance) / collectionViewSize.width, minimumAlpha)
        case .bottomToTop, .topToBottom:
            scale = max(1 - abs(distance) / collectionViewSize.height * rateOfChange, minimumScale)
            alpha = max(1 - abs(distance) / collectionViewSize.height, minimumAlpha)
        }
        
        attributes.transform = CGAffineTransformMakeScale(scale, scale)
        attributes.alpha = alpha
        if !disableCurrentCardAlwaysOnTop {
            attributes.zIndex = Int.max - 1 - Int(abs(distance))
        }
    }
    
    func applyCoverflowTransform(to attributes: UICollectionViewLayoutAttributes) {
        guard case let .coverflow(rateOfChange, maximumAngle, minimumAlpha) = cardTransformMode.options else {
            return
        }
        
        let collectionViewSize = collectionView!.bounds.size
        let distance = caculateDistance(with: attributes)
        var angle: CGFloat, alpha: CGFloat
        switch cardScrollDirection {
        case .rightToLeft, .leftToRight:
            angle = min(abs(distance) / collectionViewSize.width * (1 - rateOfChange), maximumAngle)
            alpha = max(1 - abs(distance) / collectionViewSize.width, minimumAlpha)
        case .bottomToTop, .topToBottom:
            angle = min(abs(distance) / collectionViewSize.height * (1 - rateOfChange), maximumAngle)
            alpha = max(1 - abs(distance) / collectionViewSize.height, minimumAlpha)
        }
        
        var x: CGFloat = 0, y: CGFloat = 0
        if distance < -1 {
            // 在对齐位置左侧
            switch cardScrollDirection {
            case .rightToLeft, .leftToRight:
                y = 1
            case .bottomToTop, .topToBottom:
                x = 1
                angle = -angle
            }
        } else if distance > 1 {
            // 在对齐位置右侧
            switch cardScrollDirection {
            case .rightToLeft, .leftToRight:
                y = 1
                angle = -angle
            case .bottomToTop, .topToBottom:
                x = 1
            }
        } else {
            // 在对齐位置
            angle = 0
            alpha = 1
        }
        
        var transform3D = CATransform3DIdentity
        transform3D.m34 = -0.002
        attributes.transform3D = CATransform3DRotate(transform3D, angle * .pi, x, y, 0)
        attributes.alpha = alpha
        if !disableCurrentCardAlwaysOnTop {
            attributes.zIndex = Int.max - 1 - Int(abs(distance))
        }
    }
}

fileprivate extension CardTransformLayout {
    func caculateDistance(with attributes: UICollectionViewLayoutAttributes) -> CGFloat {
        let contentOffset = collectionView!.contentOffset
        let collectionViewSize = collectionView!.bounds.size
        var distance: CGFloat
        switch cardScrollStopAlignment.options {
        case let .center(offset):
            switch cardScrollDirection {
            case .rightToLeft, .leftToRight:
                let centerX = contentOffset.x + collectionViewSize.width / 2
                distance = attributes.center.x - offset - centerX
            case .bottomToTop, .topToBottom:
                let centerY = contentOffset.y + collectionViewSize.height / 2
                distance = attributes.center.y - offset - centerY
            }
        case let .head(offset):
            switch cardScrollDirection {
            case .rightToLeft, .leftToRight:
                distance = attributes.frame.minX - offset - contentOffset.x
            case .bottomToTop, .topToBottom:
                distance = attributes.frame.minY - offset - contentOffset.y
            }
        }
        
        return distance
    }
}

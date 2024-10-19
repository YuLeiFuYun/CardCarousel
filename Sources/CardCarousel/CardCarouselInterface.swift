//
//  CardCarouselInterface.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

public protocol CardCarouselInterface {
    /// 当前进度.
    var currentProgress: CGFloat { get }
    
    /// 卡片布局尺寸，默认铺满父视图.
    func cardSize(width: CardCarousel.Dimension, height: CardCarousel.Dimension) -> Self
    
    /// 卡片变换模式，默认 .none.
    func cardTransformStyle(_ style: CardCarousel.CardTransformStyle) -> Self
    
    /// 滚动停止时卡片的对齐方式，默认 .center.
    func cardAlignment(_ alignment: CardCarousel.CardAlignment) -> Self
    
    /// 滚动方向，默认 .leftToRight.
    func scrollDirection(_ direction: CardCarousel.ScrollDirection) -> Self
    
    /// 自动滚动还是手动滚动，默认 .automatic(timeInterval: 3).
    func scrollMode(_ mode: CardCarousel.ScrollMode) -> Self
    
    /// 循环模式，默认 circular.
    func loopMode(_ mode: CardCarousel.LoopMode) -> Self
    
    /// 卡片分页阈值，默认卡片宽度的一半.
    func pagingThreshold(_ pagingThreshold: CardCarousel.PagingThreshold) -> Self
    
    /// 卡片间距，默认 .absolute(0).
    func cardSpacing(_ spacing: CardCarousel.Dimension) -> Self
    
    /// 初始时的当前卡片索引，默认 0.
    func initialCurrentCardIndex(_ index: Int) -> Self
    
    /// 一个浮点值，用于确定用户抬起手指后的减速率，值越大抬起手之后滑得越远，默认值为 0.9924.
    func decelerationRate(_ value: CGFloat) -> Self
    
    /// 禁止用户滑动.
    func disableUserSwipe() -> Self
    
    /// 禁用分页效果.
    func disablePading() -> Self
    
    /// 禁用反弹效果.
    func disableBounce() -> Self
}

protocol CardCarouselInternalType {
    var view: UIView { get }
}

public extension CardCarouselInterface {
    var currentProgress: CGFloat {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            return view.currentProgress
        }
        
        fatalError()
    }
    
    @discardableResult
    func cardSize(width: CardCarousel.Dimension, height: CardCarousel.Dimension) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.cardSize = .init(width: width, height: height)
        }
        
        return self
    }
    
    @discardableResult
    func cardSpacing(_ spacing: CardCarousel.Dimension) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.cardSpacing = spacing
        }
        
        return self
    }
    
    @discardableResult
    func initialCurrentCardIndex(_ index: Int) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.initialCurrentCardIndex = index
        }
        
        return self
    }
    
    @discardableResult
    func cardTransformStyle(_ style: CardCarousel.CardTransformStyle) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.cardTransformStyle = style
        }
        
        return self
    }
    
    @discardableResult
    func cardAlignment(_ alignment: CardCarousel.CardAlignment) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.cardAlignment = alignment
        }
        
        return self
    }
    
    @discardableResult
    func scrollDirection(_ direction: CardCarousel.ScrollDirection) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.scrollDirection = direction
        }
        
        return self
    }
    
    @discardableResult
    func scrollMode(_ mode: CardCarousel.ScrollMode) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.scrollMode = mode
        }
        
        return self
    }
    
    @discardableResult
    func loopMode(_ mode: CardCarousel.LoopMode) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.loopMode = mode
        }
        
        return self
    }
    
    @discardableResult
    func pagingThreshold(_ pagingThreshold: CardCarousel.PagingThreshold) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.pagingThreshold = pagingThreshold
        }
        
        return self
    }
    
    @discardableResult
    func decelerationRate(_ value: CGFloat) -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.decelerationRate = value
        }
        
        return self
    }
    
    @discardableResult
    func disableUserSwipe() -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.disableUserSwipe = true
        }
        
        return self
    }
    
    @discardableResult
    func disablePading() -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.isPagingEnabled = false
        }
        
        return self
    }
    
    @discardableResult
    func disableBounce() -> Self {
        if let self = self as? CardCarouselInternalType, let view = self.view as? CardCarouselView {
            view.disableBounce = true
        }
        
        return self
    }
}

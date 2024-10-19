//
//  CardCarouselDataSource.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/10/15.
//

import UIKit

public final class CardCarouselDataSource<Item> {
    // 定义 CardProvider 类型别名，用于提供卡片视图
    public typealias CardProvider = (_ cardCarousel: CardCarousel, _ index: Int, _ item: Item) -> UIView
    
    // 弱引用的 CardCarousel 实例
    private weak var cardCarousel: CardCarousel?
    
    // 存储卡片数据的数组
    private var items: [Item] = []
    
    // 卡片提供者
    private var cardProvider: CardProvider
    
    public init(cardCarousel: CardCarousel, cardProvider: @escaping CardProvider) {
        guard let view = cardCarousel.view as? CardCarouselView else { fatalError() }
        
        self.cardCarousel = cardCarousel
        self.cardProvider = cardProvider
        
        view.reloadDataClosure = { [weak self] in
            guard let self else { return }
            appendItems(items)
        }
        
        view.cardForIndexClosure = { [weak self] index in
            guard let self, !items.isEmpty else { return nil }
            return cardProvider(cardCarousel, index, items[index % items.count])
        }
    }
    
    public func appendItems(_ items: [Item]) {
        self.items = items
        guard let cardCarousel, let view = cardCarousel.view as? CardCarouselView, view.bounds.width > 0, view.bounds.height > 0, !items.isEmpty else { return }
        
        // 更新视图的总卡片数量
        view.totalCardsCount = items.count
        // 清空滚动视图的子视图
        view.scrollView.subviews.forEach { $0.removeFromSuperview() }
        // 验证初始卡片索引
        validateinitialCurrentCardIndex()
        // 更新滚动视图布局
        updateScrollViewLayout()
        
        // 计算要显示的卡片范围
        let displayCardRange = calculateDisplayCardIndex()
        // 将卡片添加到滚动视图
        addCardsToScrollView(range: displayCardRange)
        
        // 如果是自动滚动模式，设置定时器
        if case let .automatic(interval) = view.scrollMode {
            if !(view.loopMode == .single && items.count == 1) {
                view.timer?.invalidate()
                view.timer = view.makeTimer(interval: interval)
            }
        }
    }
}

private extension CardCarouselDataSource {
    // 验证初始卡片索引是否有效
    func validateinitialCurrentCardIndex() {
        guard let cardCarousel, let view = cardCarousel.view as? CardCarouselView else { return }
        guard view.initialCurrentCardIndex >= 0 && view.initialCurrentCardIndex < items.count else {
            fatalError("initialCurrentCardIndex out of range.")
        }
    }
    
    // 更新 scrollView 的 frame、contentSize 及 contentOffset
    func updateScrollViewLayout() {
        guard let cardCarousel, let view = cardCarousel.view as? CardCarouselView else { return }
        
        // scrollView 的 frame 设置后其 contentOffset 可能发生变化，其设置需要放在 contentOffset 前面
        view.scrollView.frame = cardCarousel.view.bounds
        
        let initialCurrentCardIndex = view.initialCurrentCardIndex
        let cardDimension = view.cardDimension
        let cardSpacing = view.actualCardSpacing
        let cardDimensionWithSpacing = cardDimension + cardSpacing
        let maxCardScale = view.maxCardScale
        let leadingMargin = view.leadingMargin
        let trailingMargin = view.trailingMargin
        let halfMax = view.halfMax
        
        // 根据循环模式更新滚动视图的内容尺寸和偏移
        if view.loopMode == .circular {
            let halfContentDimension = CGFloat(halfMax * items.count) * cardDimensionWithSpacing
            if view.scrollDirection.isHorizontal {
                view.scrollView.contentSize = CGSize(width: halfContentDimension * 2, height: view.bounds.height)
                view.scrollView.contentOffset = CGPoint(x: halfContentDimension + CGFloat(initialCurrentCardIndex) * cardDimensionWithSpacing, y: 0)
            } else {
                view.scrollView.contentSize = CGSize(width: view.bounds.width, height: halfContentDimension * 2)
                view.scrollView.contentOffset = CGPoint(x: 0, y: halfContentDimension + CGFloat(initialCurrentCardIndex) * cardDimensionWithSpacing)
            }
        } else {
            let value = leadingMargin + CGFloat(items.count) * cardDimensionWithSpacing + cardDimension * (maxCardScale - 1) - cardSpacing + trailingMargin
            if view.scrollDirection.isHorizontal {
                view.scrollView.contentSize = CGSize(width: value, height: view.bounds.height)
                view.scrollView.contentOffset = CGPoint(x: CGFloat(initialCurrentCardIndex) * cardDimensionWithSpacing, y: 0)
            } else {
                view.scrollView.contentSize = CGSize(width: view.bounds.width, height: value)
                view.scrollView.contentOffset = CGPoint(x: 0, y: CGFloat(initialCurrentCardIndex) * cardDimensionWithSpacing)
            }
        }
    }
    
    // 计算将要展示的卡片的索引范围
    func calculateDisplayCardIndex() -> CountableRange<Int> {
        guard let cardCarousel, let view = cardCarousel.view as? CardCarouselView else { return 0..<0 }
        
        let initialCurrentCardIndex = view.initialCurrentCardIndex
        let cardDimension = view.cardDimension
        let cardSpacing = view.actualCardSpacing
        let cardDimensionWithSpacing = cardDimension + cardSpacing
        let containerDimension = view.containerDimension
        let visibleRectExpansion = view.visibleRectExpansion
        let maxCardScale = view.maxCardScale
        let halfMax = view.halfMax
        
        // 定义前后间距变量
        var leadingSpacing: CGFloat, trailingSpacing: CGFloat
        // 根据卡片对齐方式计算前后间距
        switch view.cardAlignment.option {
        case .leading(let offset):
            leadingSpacing = offset - cardSpacing + visibleRectExpansion
            trailingSpacing = containerDimension - cardDimension * maxCardScale - offset - cardSpacing + visibleRectExpansion
        case .center(let offset):
            let baseSpacing = (containerDimension - cardDimension * maxCardScale) * 0.5
            leadingSpacing = baseSpacing + offset - cardSpacing + visibleRectExpansion
            trailingSpacing = baseSpacing - offset - cardSpacing + visibleRectExpansion
        }
        
        // 计算前后可见卡片的数量
        let leadingCount = max(Int(ceil(leadingSpacing / cardDimensionWithSpacing)), 0)
        let trailingCount = max(Int(ceil(trailingSpacing / cardDimensionWithSpacing)) + 1, 1)
        
        // 定义索引范围的上下界
        var lowerBound: Int, upperBound: Int
        // 根据循环模式计算索引范围
        if view.loopMode == .circular {
            lowerBound = halfMax * items.count + initialCurrentCardIndex - leadingCount
            upperBound = halfMax * items.count + initialCurrentCardIndex + trailingCount
        } else {
            lowerBound = max(initialCurrentCardIndex - leadingCount, 0)
            upperBound = min(initialCurrentCardIndex + trailingCount, items.count)
        }
        
        return lowerBound..<upperBound
    }
    
    // 将卡片添加到滚动视图中
    func addCardsToScrollView(range: CountableRange<Int>) {
        guard let cardCarousel, let view = cardCarousel.view as? CardCarouselView else { return }
        
        var originX: CGFloat, originY: CGFloat, scale: CGFloat, alpha: CGFloat
        for index in range {
            // 获取卡片视图
            let card = cardProvider(cardCarousel, index, items[index % items.count])
            // 计算缩放和位置
            (originX, originY, scale, alpha) = view.calculateZoomTransformValues(for: index)
            // 配置卡片视图的尺寸、缩放及透明度
            view.configureAppearanceOfCard(card, withOriginX: originX, originY: originY, scale: scale, andAlpha: alpha)
            // 添加到滚动视图
            view.scrollView.addSubview(card)
        }
    }
}

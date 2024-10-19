//
//  CardCarouselView.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

class CardCarouselView: UIView {
    // 记录开始拖拽时的内容偏移量，用于计算滑动方向和目标索引。
    private var dragStartContentOffset: CGFloat = 0
    
    // 根据 cardSize 计算得到的实际卡片尺寸
    var actualCardSize: CGSize = .zero
    
    // 用于设置卡片尺寸
    var cardSize: CardCarousel.CardSize = .init(width: .fractionalWidth(1), height: .fractionalHeight(1))
    
    // 卡片之间的间距
    var cardSpacing: CardCarousel.Dimension = .absolute(0)
    
    // 卡片之间间距的实际值
    var actualCardSpacing: CGFloat = 0
    
    // 停止滚动时卡片的对齐方式
    var cardAlignment: CardCarousel.CardAlignment = .center
    
    // 卡片是自动滚动还是手动滚动
    var scrollMode: CardCarousel.ScrollMode = .automatic(timeInterval: 3)
    
    // 循环模式
    var loopMode: CardCarousel.LoopMode = .circular
    
    // 是否启用分页效果
    var isPagingEnabled = true
    
    // 分页阈值的实际值，用于计算分页效果
    var actualPagingThreshold: CGFloat = 0.5
    
    // 分页阈值，默认 0.5
    var pagingThreshold: CardCarousel.PagingThreshold = .fractional(0.5)
    
    // 记录卡片的总数
    var totalCardsCount = 0
    
    // 初始时的当前卡片索引
    var initialCurrentCardIndex = 0
    
    // leading 边距
    var leadingMargin: CGFloat = 0
    
    // trailing 边距
    var trailingMargin: CGFloat = 0
    
    // 重新加载数据的闭包
    var reloadDataClosure: (() -> Void)?
    
    // 根据索引获取卡片视图的闭包
    var cardForIndexClosure: ((Int) -> UIView?)?
    
    // 横向滚动时为卡片宽度，纵向滚动时为卡片高度
    var cardDimension: CGFloat = 0
    
    // 卡片宽度（或高度）与卡片间距之和
    var cardDimensionWithSpacing: CGFloat = 0
    
    // 横向滚动时为自身宽度，纵向滚动时为自身高度
    var containerDimension: CGFloat = 0
    
    // 可视区域的扩展值，用于提前加载和回收卡片视图
    let visibleRectExpansion = 10.0
    
    // 卡片的最大缩放值
    var maxCardScale: CGFloat = 1
    
    // 非当前卡片的透明度
    var inactiveCardAlpha: CGFloat = 1
    
    // 循环滚动时最大圈数的一半
    let halfMax = 1000000
    
    // 定时器
    var timer: Timer?
    
    // 缓存可重用的卡片视图，以减少创建和销毁视图的性能开销
    var reusableCardCache: [String: [UIView]] = [:]
    
    // 是否对 decelerationRate 进行了自定义
    var hasCustomDecelerationRate = false
    
    // 一个浮点值，用于确定用户抬起手指后的减速率，值越大抬起手之后滑得越远
    var decelerationRate: CGFloat = 0.9924 {
        didSet {
            hasCustomDecelerationRate = true
            scrollView.decelerationRate = .init(rawValue: decelerationRate)
        }
    }
    
    // 卡片变形风格
    var cardTransformStyle: CardCarousel.CardTransformStyle = .none {
        didSet {
            if case let .zoom(maxCardScale, inactiveCardAlpha) = cardTransformStyle {
                assert(maxCardScale >= 1, "maxCardScale must be greater than or equal to 1")
                assert(inactiveCardAlpha >= 0 && inactiveCardAlpha <= 1, "inactiveCardAlpha must be between 0 and 1")
            }
        }
    }
    
    // 滚动方向
    var scrollDirection: CardCarousel.ScrollDirection = .leftToRight {
        didSet {
            switch scrollDirection {
            case .rightToLeft:
                scrollView.transform = CGAffineTransform(scaleX: -1, y: 1)
            case .bottomToTop:
                scrollView.transform = CGAffineTransform(scaleX: 1, y: -1)
            default:
                break
            }
        }
    }
    
    // 是否禁用用户滑动
    var disableUserSwipe = false {
        didSet {
            scrollView.isScrollEnabled = !disableUserSwipe
        }
    }
    
    // 是否允许反弹
    var disableBounce = false {
        didSet {
            scrollView.bounces = !disableBounce
        }
    }
    
    // 当前滚动进度，基于卡片尺寸和间距计算。
    var currentProgress: CGFloat {
        let offset = scrollDirection.isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        var progress = offset / (cardDimensionWithSpacing)
        
        if offset > 0 {
            let remainder = offset.truncatingRemainder(dividingBy: cardDimensionWithSpacing)
            if remainder < 1 {
                progress = floor(progress)
            } else if remainder + 1 > cardDimensionWithSpacing {
                progress = ceil(progress)
            }
        }
        return progress
    }
    
    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        (maxCardScale, inactiveCardAlpha) = if case let .zoom(scale, alpha) = cardTransformStyle { (scale, alpha) } else { (1, 1) }
        actualCardSize = CGSize(width: cardSize.width.resolvedValue(within: bounds.size), height: cardSize.height.resolvedValue(within: bounds.size))
        cardDimension = scrollDirection.isHorizontal ? actualCardSize.width : actualCardSize.height
        actualCardSpacing = cardSpacing.resolvedValue(within: bounds.size)
        cardDimensionWithSpacing = cardDimension + actualCardSpacing
        containerDimension = scrollDirection.isHorizontal ? bounds.width : bounds.height
        actualPagingThreshold = pagingThreshold.resolvedPagingThreshold(cardDimensionWithSpacing: cardDimensionWithSpacing)
        isPagingEnabled = if case .automatic = scrollMode { true } else { isPagingEnabled }
        updateMargin()
        reloadDataClosure?()
    }
}

extension CardCarouselView: UIScrollViewDelegate {
    /// 当 scrollView 滚动时调用，用于更新可见卡片和管理卡片的加载与回收。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 存储当前可见卡片的信息，包括索引和 frame
        var visibleCardsInfo: [(index: Int, frame: CGRect)] = []
        // 计算扩展的可见区域和边界位置
        let (extendedVisibleRect, leadingPosition, trailingPosition) = calculateExtendedVisibleRect()
        // 更新现有卡片的信息
        updateExistingCards(visibleCardsInfo: &visibleCardsInfo, extendedVisibleRect: extendedVisibleRect)
        
        // 如果之前的卡片都已被移除
        if visibleCardsInfo.isEmpty {
            // 根据边界位置添加边界卡片到滚动视图中
            addBoundaryCardsToScrollViewIfNeeded(leadingPosition: leadingPosition, trailingPosition: trailingPosition)
        } else {
            // 如果有可见的卡片，添加相邻的卡片
            addAdjacentCardsIfNeeded(
                basedOn: visibleCardsInfo.sorted { $0.index < $1.index },
                leadingPosition: leadingPosition,
                trailingPosition: trailingPosition
            )
        }
    }
    
    /// 当用户开始拖拽 scrollView 时调用，记录拖拽开始时的内容偏移量。
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
        timer = nil
        dragStartContentOffset = scrollDirection.isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
    }
    
    /// 当用户结束拖拽 scrollView 时调用，计算并设置目标内容偏移量以实现分页效果。
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 如果分页功能未启用，则直接返回
        guard isPagingEnabled else { return }
        
        // 检测滑动方向，向前还是向后
        let slideDirection = determineScrollDirection(velocity: velocity.x + velocity.y)
        // 计算目标页面索引
        let targetPageIndex = calculateTargetPageIndex(for: targetContentOffset.pointee, slideDirection: slideDirection)
        // 根据滚动方向设置目标内容偏移
        if scrollDirection.isHorizontal {
            targetContentOffset.pointee = CGPoint(x: CGFloat(targetPageIndex) * cardDimensionWithSpacing, y: 0)
        } else {
            targetContentOffset.pointee = CGPoint(x: 0, y: CGFloat(targetPageIndex) * cardDimensionWithSpacing)
        }
    }
    
    /// 手指离开屏幕后 scrollView 还会继续滚动一段时间直到停止后才会执行。
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if case let .automatic(interval) = scrollMode, loopMode != .single {
            timer = makeTimer(interval: interval)
        }
    }
    
    /// 当调用 setContentOffset(_ contentOffset: CGPoint, animated: Bool)，并且 animated 参数为 true 时,会在 scrollView 滚动结束时调用。
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if loopMode == .single, currentProgress == CGFloat(totalCardsCount - 1) {
            timer?.invalidate()
            timer = nil
        }
    }
}

extension CardCarouselView {
    /// 设置 scrollView 的基本属性并将其添加到视图中。
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    /// 更新 margin
    private func updateMargin() {
        switch cardAlignment.option {
        case .leading(let offset):
            leadingMargin = offset
            trailingMargin = containerDimension - cardDimension * maxCardScale - offset
        case .center(let offset):
            leadingMargin = (containerDimension - cardDimension * maxCardScale) * 0.5 + offset
            trailingMargin = (containerDimension - cardDimension * maxCardScale) * 0.5 - offset
        }
    }
    
    /// 计算扩展的可视区域及其前后边界位置，用于确定哪些卡片应该被加载或回收。
    private func calculateExtendedVisibleRect() -> (CGRect, CGFloat, CGFloat) {
        var extendedVisibleRect: CGRect, leadingPosition: CGFloat, trailingPosition: CGFloat
        if scrollDirection.isHorizontal {
            extendedVisibleRect = CGRect(
                x: scrollView.contentOffset.x - visibleRectExpansion, y: 0,
                width: bounds.width + 2 * visibleRectExpansion, height: bounds.height
            )
            leadingPosition = scrollView.contentOffset.x - visibleRectExpansion
            trailingPosition = scrollView.contentOffset.x + bounds.width + visibleRectExpansion
        } else {
            extendedVisibleRect = CGRect(
                x: 0, y: scrollView.contentOffset.y - visibleRectExpansion,
                width: bounds.width, height: bounds.height + 2 * visibleRectExpansion
            )
            leadingPosition = scrollView.contentOffset.y - visibleRectExpansion
            trailingPosition = scrollView.contentOffset.y + bounds.height + visibleRectExpansion
        }
        
        return (extendedVisibleRect, leadingPosition, trailingPosition)
    }
    
    /// 更新现有卡片的外观和可见性信息
    private func updateExistingCards(visibleCardsInfo: inout [(index: Int, frame: CGRect)], extendedVisibleRect: CGRect) {
        // 遍历滚动视图中的所有子视图（卡片）
        scrollView.subviews.forEach { card in
            // 计算卡片的缩放、位置和透明度
            let (originX, originY, scale, alpha) = calculateZoomTransformValues(for: card._index)
            // 配置卡片的外观
            configureAppearanceOfCard(card, withOriginX: originX, originY: originY, scale: scale, andAlpha: alpha)
            
            // 检查卡片的框架是否与扩展的可见区域相交
            if extendedVisibleRect.intersects(card.frame) {
                // 如果相交，将卡片的索引和框架信息添加到可见卡片信息数组中
                visibleCardsInfo.append((card._index, card.frame))
            } else {
                // 如果不相交，重用卡片
                cacheAndRemoveCard(card)
            }
        }
    }

    
    /// 将指定的视图对象放入重用缓存中，并从其父视图中移除。
    private func cacheAndRemoveCard(_ card: UIView) {
        // 获取视图对象的类型名称作为重用标识符
        let reuseIdentifier = String(describing: type(of: card))
        // 将视图对象添加到重用缓存中。如果缓存中不存在该类型的数组，则创建一个新数组。
        reusableCardCache[reuseIdentifier, default: []].append(card)
        // 从其父视图中移除该视图对象
        card.removeFromSuperview()
    }
    
    /// 根据需要添加边界处的卡片视图。
    private func addBoundaryCardsToScrollViewIfNeeded(leadingPosition: CGFloat, trailingPosition: CGFloat) {
        addCardToScrollViewIfNeeded(at: 0, leadingPosition: leadingPosition, trailingPosition: trailingPosition)
        if totalCardsCount > 1 {
            addCardToScrollViewIfNeeded(at: totalCardsCount - 1, leadingPosition: leadingPosition, trailingPosition: trailingPosition)
        }
    }
    
    /// 根据当前滚动位置和卡片的位置，决定是否需要将卡片添加到 scrollView 中。
    private func addCardToScrollViewIfNeeded(at index: Int, leadingPosition: CGFloat, trailingPosition: CGFloat) {
        // 计算卡片的位置、缩放比例和透明度
        let (originX, originY, scale, alpha) = calculateZoomTransformValues(for: index)
        // 根据滚动方向确定卡片的位置
        let position = scrollDirection.isHorizontal ? originX : originY
        // 判断卡片是否位于滚动视图的前端边界内
        let isWithinLeadingBounds = position > leadingPosition && position <= leadingPosition + visibleRectExpansion
        // 判断卡片是否位于滚动视图的后端边界内
        let isWithinTrailingBounds = position < trailingPosition && position >= trailingPosition - visibleRectExpansion
        // 如果卡片位于前端或后端边界内，则需要添加
        let requiresAdding = isWithinLeadingBounds || isWithinTrailingBounds
        
        if requiresAdding {
            // 通过闭包获取卡片实例
            if let card = cardForIndexClosure?(index) {
                // 配置卡片的外观
                configureAppearanceOfCard(card, withOriginX: originX, originY: originY, scale: scale, andAlpha: alpha)
                // 将卡片添加到滚动视图中
                scrollView.addSubview(card)
            }
        }
    }
    
    /// 根据已有的可见卡片信息，添加将要显示的卡片视图。
    private func addAdjacentCardsIfNeeded(basedOn visibleCardsInfo: [(index: Int, frame: CGRect)], leadingPosition: CGFloat, trailingPosition: CGFloat) {
        // 获取第一张可见卡片的信息
        let firstCardInfo = visibleCardsInfo[0]
        var cardIndex = firstCardInfo.index
        var cardFrame = firstCardInfo.frame
        // 根据滚动方向，获取卡片的起始位置
        var position = scrollDirection.isHorizontal ? cardFrame.minX : cardFrame.minY
        
        // 如果第一张可见卡片的索引大于 0，并且在它前面有足够的空间，则在它前面添加一张卡片
        if cardIndex > 0 {
            if position - actualCardSpacing > leadingPosition {
                addCardToScrollView(index: cardIndex - 1)
            }
        }
        
        // 检查最后一张可见卡片的信息
        if let lastCardInfo = visibleCardsInfo.last {
            // 如果是循环模式或者还有更多的卡片可以添加，则检查是否需要在后面添加卡片
            if loopMode == .circular || lastCardInfo.index + 1 < totalCardsCount {
                cardIndex = lastCardInfo.index
                cardFrame = lastCardInfo.frame
                // 根据滚动方向，获取卡片的结束位置
                position = scrollDirection.isHorizontal ? cardFrame.maxX : cardFrame.maxY
                // 如果有足够的空间，则在后面添加一张卡片
                if position + actualCardSpacing < trailingPosition {
                    addCardToScrollView(index: cardIndex + 1)
                }
            }
        }
    }
    
    /// 将指定索引的卡片添加到 scrollView 中。
    private func addCardToScrollView(index: Int) {
        let (originX, originY, scale, alpha) = calculateZoomTransformValues(for: index)
        if let card = cardForIndexClosure?(index) {
            configureAppearanceOfCard(card, withOriginX: originX, originY: originY, scale: scale, andAlpha: alpha)
            scrollView.addSubview(card)
        }
    }
    
    /// 检测 scrollView 是向前还是向后滚动。
    private func determineScrollDirection(velocity: CGFloat) -> CardCarousel.SlideDirection {
        var slideDirection: CardCarousel.SlideDirection
        if velocity == 0 {
            if dragStartContentOffset > scrollView.contentOffset.x + scrollView.contentOffset.y {
                slideDirection = .backward
            } else {
                slideDirection = .forward
            }
        } else if velocity > 0 {
            slideDirection = .forward
        } else {
            slideDirection = .backward
        }
        
        return slideDirection
    }
    
    /// 根据预期目标位置、向前还是向后滚动以及是否对 scrollView 的减速速率进行了自定义计算目标索引
    private func calculateTargetPageIndex(for targetOffset: CGPoint, slideDirection: CardCarousel.SlideDirection) -> Int {
        // 根据滚动方向获取目标偏移量
        let offset = scrollDirection.isHorizontal ? targetOffset.x : targetOffset.y
        // 计算目标索引处的进度值
        let progress = offset / cardDimensionWithSpacing
        // 默认目标页面索引为 0
        var targetPageIndex = 0
        
        if offset <= 0 {
            // 如果偏移量小于等于 0，目标页面索引保持为 0
            targetPageIndex = 0
        } else if loopMode == .single, progress >= CGFloat(totalCardsCount - 1) {
            // 如果是单次循环模式，并且进度超过了最后一页，目标页面索引设置为最后一页
            targetPageIndex = totalCardsCount - 1
        } else {
            // 根据滑动方向和实际分页阈值计算目标页面索引
            if slideDirection == .forward {
                // 向前滑动
                if progress - floor(progress) >= actualPagingThreshold {
                    targetPageIndex = Int(ceil(progress))
                } else {
                    targetPageIndex = Int(floor(progress))
                }
            } else {
                // 向后滑动
                if progress - floor(progress) <= 1 - actualPagingThreshold {
                    targetPageIndex = Int(floor(progress))
                } else {
                    targetPageIndex = Int(ceil(progress))
                }
            }
        }
        
        // 如果没有自定义减速率，则根据拖拽开始时的偏移量调整目标页面索引
        if !hasCustomDecelerationRate {
            let prevProgress = dragStartContentOffset / cardDimensionWithSpacing
            let prevIndex = Int(floor(prevProgress))
            if targetPageIndex > prevIndex {
                targetPageIndex = prevIndex + 1
            } else if targetPageIndex < prevIndex {
                targetPageIndex = prevIndex - 1
            }
        }
        
        return targetPageIndex
    }

    /// 创建定时器
    func makeTimer(interval: TimeInterval) -> Timer? {
        return .scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            let targetOffset = (ceil(currentProgress) + 1) * cardDimensionWithSpacing
            if scrollDirection.isHorizontal {
                scrollView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: true)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: true)
            }
        }
    }
    
    /// 配置卡片的外观，包括透明度、变换（缩放和翻转）以及中心位置
    func configureAppearanceOfCard(_ card: UIView, withOriginX originX: CGFloat, originY: CGFloat, scale: CGFloat, andAlpha alpha: CGFloat) {
        // 设置卡片的透明度
        card.alpha = alpha
        
        // 根据滚动方向应用变换
        switch scrollDirection {
        case .leftToRight, .topToBottom:
            // 对于从左到右或从上到下的滚动方向，直接应用缩放变换
            card.transform = CGAffineTransform(scaleX: scale, y: scale)
        case .rightToLeft:
            // 对于从右到左的滚动方向，先应用水平翻转变换，再应用缩放变换
            card.transform = CGAffineTransformConcat(CGAffineTransform(scaleX: -1, y: 1), CGAffineTransform(scaleX: scale, y: scale))
        case .bottomToTop:
            // 对于从下到上的滚动方向，先应用垂直翻转变换，再应用缩放变换
            card.transform = CGAffineTransformConcat(CGAffineTransform(scaleX: 1, y: -1), CGAffineTransform(scaleX: scale, y: scale))
        }
        
        // 设置卡片的中心位置，考虑到缩放后的尺寸
        card.center = CGPoint(
            x: originX + actualCardSize.width * scale * 0.5,
            y: originY + actualCardSize.height * scale * 0.5
        )
    }
    
    /// 根据卡片索引计算卡片的缩放值和位置
    func calculateZoomTransformValues(for index: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let baseDimension = leadingMargin + CGFloat(index) * cardDimensionWithSpacing
        var originX: CGFloat = scrollDirection.isHorizontal ? baseDimension : (bounds.width - actualCardSize.width) * 0.5
        var originY: CGFloat = scrollDirection.isHorizontal ? (bounds.height - actualCardSize.height) * 0.5 : baseDimension
        var scale: CGFloat = 1
        if currentProgress <= 0 {
            if currentProgress > -1 {
                scale = (1 + currentProgress) * (maxCardScale - 1) + 1
                if scrollDirection.isHorizontal {
                    if index == 0 {
                        originY = (bounds.height - actualCardSize.height * scale) * 0.5
                    } else {
                        originX = baseDimension + cardDimension * (scale - 1)
                    }
                } else {
                    if index == 0 {
                        originX = (bounds.width - actualCardSize.width * scale) * 0.5
                    } else {
                        originY = baseDimension + cardDimension * (scale - 1)
                    }
                }
                
                if index != 0 { scale = 1 }
            }
        } else if loopMode == .single, currentProgress >= CGFloat(totalCardsCount - 1) {
            if currentProgress < CGFloat(totalCardsCount), index == totalCardsCount - 1 {
                scale = (CGFloat(totalCardsCount) - currentProgress) * (maxCardScale - 1) + 1
                if scrollDirection.isHorizontal {
                    originY = (bounds.height - actualCardSize.height * scale) * 0.5
                } else {
                    originX = (bounds.width - actualCardSize.width * scale) * 0.5
                }
            }
        } else {
            let lowerIndex = Int(currentProgress)
            let upperIndex = lowerIndex + 1
            if index == lowerIndex {
                scale = (CGFloat(upperIndex) - currentProgress) * (maxCardScale - 1) + 1
                if scrollDirection.isHorizontal {
                    originY = (bounds.height - actualCardSize.height * scale) * 0.5
                } else {
                    originX = (bounds.width - actualCardSize.width * scale) * 0.5
                }
            } else if index == upperIndex {
                scale = (currentProgress - CGFloat(lowerIndex)) * (maxCardScale - 1) + 1
                if scrollDirection.isHorizontal {
                    originX = baseDimension + (maxCardScale - scale) * cardDimension
                    originY = (bounds.height - actualCardSize.height * scale) * 0.5
                } else {
                    originX = (bounds.width - actualCardSize.width * scale) * 0.5
                    originY = baseDimension + (maxCardScale - scale) * cardDimension
                }
            } else if index > upperIndex {
                if scrollDirection.isHorizontal {
                    originX = baseDimension + (maxCardScale - 1) * cardDimension
                } else {
                    originY = baseDimension + (maxCardScale - 1) * cardDimension
                }
            }
        }
        
        var alpha: CGFloat = 1
        if case .zoom(_, _) = cardTransformStyle {
            alpha = inactiveCardAlpha + (scale - 1) * (1 - inactiveCardAlpha) / (maxCardScale - 1)
        }
        return (originX, originY, scale, alpha)
    }
}

extension UIView {
    private struct AssociatedKeys {
        static var index: UInt8 = 0
    }
    
    var _index: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.index) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.index, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

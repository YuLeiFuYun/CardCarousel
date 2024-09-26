//
//  CardCarouselCore.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import Combine
import UIKit

public class CardCarouselCore<Item>: CardCarouselBaseView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching, UICollectionViewDataSource {
    private let halfMaxLoopCount = 50000
    
    private var indexAtDraggingStart = 0
    
    private var contentOffsetAtDraggingStart: CGFloat = 0
    
    private var currentPageIndex = 0
    
    public var items: [Item] = [] {
        didSet {
            updateUIOnLayoutChange()
        }
    }
    
    public override var indicesForVisiblePages: [Int] {
        collectionView.indexPathsForVisibleItems.map { $0.row % items.count }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 重写 CardCarouselBaseView 方法
    
    override func makeTimer(interval: TimeInterval) -> GCDTimer? {
        guard items.count > 1 else { return nil }
        
        let timer = GCDTimer(interval: .milliseconds(Int(interval * 1000))) { [weak self] timer in
            self?.scrollToNearestPage()
        }
        return timer
    }
    
    override func updateUIOnLayoutChange() {
        let size = cardLayoutSize.actualValue(withContainerSize: collectionView.frame.size)
        guard size.width > 0, size.height > 0, !items.isEmpty else { return }
        
        cardSize = size
        pageControl?.numberOfPages = items.count
        pageControl?.isHidden = items.count <= 1
        currentPageIndex = loopMode == .circular && items.count > 1 ? items.count * halfMaxLoopCount : 0
        collectionView.reloadData()
        
        if case .automatic(let timeInterval) = scrollMode {
            timer = makeTimer(interval: timeInterval)
        } else {
            timer = nil
        }
        
        collectionView.performBatchUpdates(nil) { [weak self] _ in
            guard let self = self else { return }
            
            self.collectionView.contentOffset = self.calculateContentOffset(atPageIndex: self.currentPageIndex)
            onCardChanged?(0)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loopMode == .circular && items.count > 1 ? items.count * halfMaxLoopCount * 2 : items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let onPrefetchItems {
            let indexPaths = indexPaths.map { IndexPath(row: $0.row % items.count, section: $0.section) }
            onPrefetchItems(indexPaths)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if let onCancelPrefetchingForItems {
            let indexPaths = indexPaths.map { IndexPath(row: $0.row % items.count, section: $0.section) }
            onCancelPrefetchingForItems(indexPaths)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onCardSelected?(indexPath.row % items.count)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if scrollDirection == .bottomToTop {
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        
        cell.layer.cornerRadius = cardCornerRadius
        cell.layer.masksToBounds = true
        if !cardMaskedCorners.isEmpty {
            cell.layer.maskedCorners = cardMaskedCorners
        }
        
        cell.layer.borderWidth = cardBorderWidth
        cell.layer.borderColor = cardBorderColor
        cell.layer.shadowColor = cardShadowColor
        cell.layer.shadowOpacity = cardShadowOpacity
        cell.layer.shadowRadius = cardShadowRadius
        cell.layer.shadowOffset = cardShadowOffset
        cell.layer.shadowPath = cardShadowPath
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var horizontalInset: CGFloat = 0, verticalInset: CGFloat = 0
        
        switch loopMode {
        case .circular:
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                switch cardScrollStopAlignment.options {
                case let .center(offset):
                    horizontalInset = (collectionView.bounds.width - cardSize.width) / 2 + offset
                case let .head(offset):
                    horizontalInset = offset
                }
                
                verticalInset = (collectionView.bounds.height - cardSize.height) / 2
            case .bottomToTop, .topToBottom:
                switch cardScrollStopAlignment.options {
                case let .center(offset):
                    verticalInset = (collectionView.bounds.height - cardSize.height) / 2 + offset
                case let .head(offset):
                    verticalInset = offset
                }
                
                horizontalInset = (collectionView.bounds.width - cardSize.width) / 2
            }
        default:
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                horizontalInset = sideMargin
                verticalInset = (collectionView.bounds.height - cardSize.height) / 2
            case .bottomToTop, .topToBottom:
                horizontalInset = (collectionView.bounds.width - cardSize.width) / 2
                verticalInset = sideMargin
            }
        }
        
        return UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = calculateAdjustedContentOffset(currentContentOffset: scrollView.contentOffset)
        let progress = calculateProgress(atContentOffset: scrollView.contentOffset)
        let adjustedProgress = roundProgressNearBounds(progress)
        onScroll?(offset, adjustedProgress)
        
        if let pageControl = pageControl as? CardCarouselContinousPageControlType {
            pageControl.progress = adjustedProgress
        } else if let pageControl = pageControl as? CardCarouselNormalPageControlType {
            pageControl.currentPage = Int(adjustedProgress)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer = nil
        indexAtDraggingStart = calculateIndexOfPage(atContentOffset: scrollView.contentOffset, slideDirection: .forward)
        contentOffsetAtDraggingStart = scrollView.contentOffset.x + scrollView.contentOffset.y
        
        onWillBeginDragging?(indexAtDraggingStart % items.count)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let slideDirection = determineScrollDirection(velocity: velocity.x + velocity.y)
        var targetPageIndex = calculateIndexOfPage(atContentOffset: targetContentOffset.pointee, slideDirection: slideDirection)
        guard !isCustomDecelerationRate else {
            targetContentOffset.pointee = calculateContentOffset(atPageIndex: targetPageIndex)
            onWillEndDragging?(targetPageIndex % items.count)
            return
        }
        
        if targetPageIndex > indexAtDraggingStart {
            targetPageIndex = indexAtDraggingStart + 1
        } else if targetPageIndex < indexAtDraggingStart {
            targetPageIndex = indexAtDraggingStart - 1
        }
        
        targetContentOffset.pointee = calculateContentOffset(atPageIndex: targetPageIndex)
        onWillEndDragging?(targetPageIndex % items.count)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPageIndex = calculateIndexOfPage(atContentOffset: collectionView.contentOffset, slideDirection: .forward)
        if let pageControl = pageControl as? CardCarouselContinousPageControlType {
            pageControl.progress = CGFloat(currentPageIndex % items.count)
        } else if let pageControl = pageControl as? CardCarouselNormalPageControlType {
            pageControl.currentPage = currentPageIndex % items.count
        }
        onCardChanged?(currentPageIndex % items.count)
        
        if case .automatic(let timeInterval) = scrollMode, loopMode != .single {
            timer = makeTimer(interval: timeInterval)
            timer?.resume()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateAfterScrollingAnimationEnds()
    }
}

private extension CardCarouselCore {
    func scrollToNearestPage() {
        let indexOfNearestPage = calculateIndexOfNearestPage(slideDirection: .forward)
        let contentOffset = calculateContentOffset(atPageIndex: indexOfNearestPage)
        if autoScrollAnimationOptions.duration <= 0 {
            collectionView.setContentOffset(contentOffset, animated: true)
        } else {
            collectionView.setContentOffset(
                contentOffset, duration: autoScrollAnimationOptions.duration,
                timingFunction: autoScrollAnimationOptions.timingFunction
            ) { [weak self] in
                self?.updateAfterScrollingAnimationEnds()
            }
        }
    }
    
    func roundProgressNearBounds(_ progress: Double) -> Double {
        let integerPart = Double(Int(progress))
        let fractionPart = progress - integerPart
        if fractionPart >= 0.98 {
            return integerPart + 1
        } else if fractionPart <= 0.02 {
            return integerPart
        }
        return progress
    }
    
    func calculateAdjustedContentOffset(currentContentOffset offset: CGPoint) -> CGPoint {
        var offset = offset
        if loopMode == .circular {
            var x: CGFloat = 0, y: CGFloat = 0, stride: CGFloat
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                stride = cardSize.width + minimumLineSpacing
                x = offset.x.truncatingRemainder(dividingBy: (CGFloat(items.count) * stride))
            case .bottomToTop, .topToBottom:
                stride = cardSize.height + minimumLineSpacing
                y = offset.y.truncatingRemainder(dividingBy: (CGFloat(items.count) * stride))
            }
            
            offset = CGPoint(x: x, y: y)
        }
        
        return offset
    }
    
    func calculateProgress(atContentOffset contentOffset: CGPoint) -> CGFloat {
        var stride: CGFloat, progress: CGFloat
        switch loopMode {
        case .circular:
            var x: CGFloat = 0, y: CGFloat = 0
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                stride = cardSize.width + minimumLineSpacing
                x = contentOffset.x.truncatingRemainder(dividingBy: (CGFloat(items.count) * stride))
                progress = x / stride
            case .bottomToTop, .topToBottom:
                stride = cardSize.height + minimumLineSpacing
                y = contentOffset.y.truncatingRemainder(dividingBy: (CGFloat(items.count) * stride))
                progress = y / stride
            }
        default:
            switch scrollDirection {
            case .leftToRight, .rightToLeft:
                progress = 0
                stride = cardSize.width + minimumLineSpacing
                if case let .center(offset) = cardScrollStopAlignment.options {
                    let distance = contentOffset.x + bounds.width * 0.5 + offset
                    progress = (distance - sideMargin - cardSize.width * 0.5) / stride
                    let criticalValue = sideMargin + stride * CGFloat(items.count - 1) - stride * 0.5 - minimumLineSpacing
                    if distance > criticalValue {
                        if bounds.width * 0.5 - offset >= cardSize.width * 1.5 + minimumLineSpacing + sideMargin {
                            progress = CGFloat(items.count - 1)
                        } else {
                            let lastStride = cardSize.width * 1.5 + minimumLineSpacing + sideMargin - bounds.width * 0.5 + offset
                            progress = CGFloat(items.count - 2) + (contentOffset.x + bounds.width - criticalValue - bounds.width * 0.5 + offset) / lastStride
                        }
                    } else {
                        let value = (bounds.width * 0.5 + offset - sideMargin - cardSize.width * 0.5) / stride
                        stride = (ceil(value) - value) * stride
                        if contentOffset.x < stride {
                            progress = contentOffset.x / stride
                        }
                    }
                } else if case let .head(offset) = cardScrollStopAlignment.options {
                    let distance = contentOffset.x + offset
                    progress = (distance - sideMargin) / stride
                    let criticalValue = sideMargin + stride * CGFloat(items.count - 1)
                    if distance > criticalValue {
                        if bounds.width - offset >= cardSize.width + sideMargin {
                            progress = CGFloat(items.count - 1)
                        } else {
                            let lastStride = cardSize.width + sideMargin - bounds.width + offset
                            progress = CGFloat(items.count - 2) + (contentOffset.x - criticalValue + offset) / lastStride
                        }
                    } else {
                        let value = (offset - sideMargin) / stride
                        stride = (ceil(value) - value) * stride
                        if contentOffset.x < stride {
                            progress = contentOffset.x / stride
                        }
                    }
                }
            case .topToBottom, .bottomToTop:
                progress = 0
                stride = cardSize.height + minimumLineSpacing
                if case let .center(offset) = cardScrollStopAlignment.options {
                    let distance = contentOffset.y + bounds.height * 0.5 + offset
                    progress = (distance - sideMargin - cardSize.height * 0.5) / stride
                    let criticalValue = sideMargin + stride * CGFloat(items.count - 1) - stride * 0.5 - minimumLineSpacing
                    if distance > criticalValue {
                        if bounds.height * 0.5 - offset >= cardSize.height * 1.5 + minimumLineSpacing + sideMargin {
                            progress = CGFloat(items.count - 1)
                        } else {
                            let lastStride = cardSize.height * 1.5 + minimumLineSpacing + sideMargin - bounds.height * 0.5 + offset
                            progress = CGFloat(items.count - 2) + (contentOffset.y + bounds.height - criticalValue - bounds.height * 0.5 + offset) / lastStride
                        }
                    } else {
                        let value = (bounds.height * 0.5 + offset - sideMargin - cardSize.height * 0.5) / stride
                        stride = (ceil(value) - value) * stride
                        if contentOffset.y < stride {
                            progress = contentOffset.y / stride
                        }
                    }
                } else if case let .head(offset) = cardScrollStopAlignment.options {
                    let distance = contentOffset.y + offset
                    progress = (distance - sideMargin) / stride
                    let criticalValue = sideMargin + stride * CGFloat(items.count - 1)
                    if distance > criticalValue {
                        if bounds.height - offset >= cardSize.height + sideMargin {
                            progress = CGFloat(items.count - 1)
                        } else {
                            let lastStride = cardSize.height + sideMargin - bounds.height + offset
                            progress = CGFloat(items.count - 2) + (contentOffset.y - criticalValue + offset) / lastStride
                        }
                    } else {
                        let value = (offset - sideMargin) / stride
                        stride = (ceil(value) - value) * stride
                        if contentOffset.y < stride {
                            progress = contentOffset.y / stride
                        }
                    }
                }
            }
        }
        
        return progress
    }
    
    func updateAfterScrollingAnimationEnds() {
        guard !items.isEmpty else { return }
        
        currentPageIndex = calculateIndexOfPage(atContentOffset: collectionView.contentOffset, slideDirection: .forward)
        if let pageControl = pageControl as? CardCarouselContinousPageControlType {
            pageControl.progress = CGFloat(currentPageIndex % items.count)
        } else if let pageControl = pageControl as? CardCarouselNormalPageControlType {
            pageControl.currentPage = currentPageIndex % items.count
        }
        onCardChanged?(currentPageIndex % items.count)
        
        if loopMode == .single && currentPageIndex == items.count - 1 {
            timer = nil
        } else if loopMode == .circular && currentPageIndex % items.count == 0 {
            currentPageIndex = items.count * halfMaxLoopCount
            collectionView.contentOffset = calculateContentOffset(atPageIndex: currentPageIndex)
        }
    }
    
    func determineScrollDirection(velocity: CGFloat) -> SlideDirection {
        var slideDirection: SlideDirection
        if velocity == 0 {
            if contentOffsetAtDraggingStart > collectionView.contentOffset.x + collectionView.contentOffset.y {
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
    
    func calculateIndexOfNearestPage(slideDirection: SlideDirection) -> Int {
        var indexOfNearestPage = 0
        switch slideDirection {
        case .forward:
            if currentPageIndex % items.count == items.count - 1 {
                switch loopMode {
                case .circular: indexOfNearestPage = currentPageIndex + 1
                case .rollback: indexOfNearestPage = 0
                case .single: indexOfNearestPage = items.count - 1
                }
            } else {
                indexOfNearestPage = currentPageIndex + 1
            }
        case .backward:
            if currentPageIndex % items.count == 0 {
                switch loopMode {
                case .circular: indexOfNearestPage = currentPageIndex - 1
                case .rollback: indexOfNearestPage = items.count - 1
                case .single: indexOfNearestPage = 0
                }
            } else {
                indexOfNearestPage = currentPageIndex - 1
            }
        }
        
        return indexOfNearestPage
    }
    
    func calculateIndexOfPage(atContentOffset offset: CGPoint, slideDirection: SlideDirection) -> Int {
        let stepLength = calculateStepLengthBasedOnScrollDirection()
        let floatIndex = calculateFloatIndex(forOffset: offset, withStepLength: stepLength)
        let pageIndex = calculatePageIndex(fromFloatIndex: floatIndex, withStepLength: stepLength, slideDirection: slideDirection)
        
        return min(pageIndex, collectionView.numberOfItems(inSection: 0))
    }
    
    func calculateContentOffset(atPageIndex index: Int) -> CGPoint {
        var contentOffset: CGPoint = .zero
        if index == 0 {
            if items.count == 1 {
                contentOffset = calculateContentOffsetWhenOnlyOnePage()
            }
        } else if loopMode != .circular && index == items.count - 1 {
            contentOffset = calculateLastPageContentOffset()
        } else {
            contentOffset = calculateIntermediatePageContentOffset(atIndex: index)
        }
        
        return contentOffset
    }
}

private extension CardCarouselCore {
    func calculateStepLengthBasedOnScrollDirection() -> CGFloat {
        switch scrollDirection {
        case .leftToRight, .rightToLeft:
            return cardSize.width + minimumLineSpacing
        case .topToBottom, .bottomToTop:
            return cardSize.height + minimumLineSpacing
        }
    }
    
    func calculateFloatIndex(forOffset offset: CGPoint, withStepLength stepLength: CGFloat) -> CGFloat {
        var floatIndex: CGFloat
        if loopMode == .circular {
            floatIndex = (offset.x + offset.y) / stepLength
        } else {
            floatIndex = calculateProgress(atContentOffset: offset)
        }
        
        return floatIndex
    }
    
    func calculatePageIndex(fromFloatIndex floatIndex: CGFloat, withStepLength stepLength: CGFloat, slideDirection: SlideDirection) -> Int {
        var pageIndex = Int(floatIndex)
        let decimalPart = floatIndex - CGFloat(pageIndex)
        switch cardPagingThreshold {
        case .fractional(let value):
            switch slideDirection {
            case .forward:
                if decimalPart > value - 0.01 {
                    pageIndex += 1
                }
            case .backward:
                if decimalPart > 0.99 - value {
                    pageIndex += 1
                }
            }
        case .absolute(let value):
            switch slideDirection {
            case .forward:
                if decimalPart * stepLength > value {
                    pageIndex += 1
                }
            case .backward:
                if decimalPart * stepLength > stepLength - value {
                    pageIndex += 1
                }
            }
        }
        
        return pageIndex
    }
    
    func calculateContentOffsetWhenOnlyOnePage() -> CGPoint {
        var contentOffset: CGPoint = .zero
        switch scrollDirection {
        case .rightToLeft, .leftToRight:
            switch singleCardAlignment.options {
            case let .center(offset):
                contentOffset.x = sideMargin + (cardSize.width - bounds.width) / 2 - offset
            case let .head(offset):
                contentOffset.x = sideMargin - offset
            }
        case .bottomToTop, .topToBottom:
            switch singleCardAlignment.options {
            case let .center(offset):
                contentOffset.y = sideMargin + (cardSize.height - bounds.height) / 2 - offset
            case let .head(offset):
                contentOffset.y = sideMargin - offset
            }
        }
        
        return contentOffset
    }
    
    func calculateLastPageContentOffset() -> CGPoint {
        var contentOffset: CGPoint = .zero
        switch scrollDirection {
        case .rightToLeft, .leftToRight:
            contentOffset.x = collectionView.contentSize.width - bounds.width
        case .bottomToTop, .topToBottom:
            contentOffset.y = collectionView.contentSize.height - bounds.height
        }
        
        return contentOffset
    }
    
    func calculateIntermediatePageContentOffset(atIndex index: Int) -> CGPoint {
        var contentOffset: CGPoint = .zero, delta: CGFloat
        switch loopMode {
        case .circular: delta = 0
        default:
            switch cardScrollStopAlignment.options {
            case let .center(offset):
                switch scrollDirection {
                case .rightToLeft, .leftToRight:
                    delta = sideMargin + (cardSize.width - bounds.width) / 2 - offset
                case .bottomToTop, .topToBottom:
                    delta = sideMargin + (cardSize.height - bounds.height) / 2 - offset
                }
            case let .head(offset): delta = sideMargin - offset
            }
        }
        
        let stepLength = calculateStepLengthBasedOnScrollDirection()
        switch scrollDirection {
        case .rightToLeft, .leftToRight:
            contentOffset.x = stepLength * CGFloat(index) + delta
        case .bottomToTop, .topToBottom:
            contentOffset.y = stepLength * CGFloat(index) + delta
        }
        
        return contentOffset
    }
}

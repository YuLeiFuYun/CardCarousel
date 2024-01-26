//
//  CardCarouselCore.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import Combine
import UIKit

fileprivate let halfMaxLoopCount = 50000

public class CardCarouselCore<Item>: CardCarouselBaseView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching, UICollectionViewDataSource {
    private var indexAtBeginOfDragging = 0
    
    private var contentOffsetAtBeginOfDragging: CGFloat = 0
    
    private var indexOfCurrentPage = 0
    
    let imageFetcher = ImageFetcher()
    
    public var data: [Item] = [] {
        didSet {
            updateUIForStateChanged()
        }
    }
    
    public override var indicesForVisiblePages: [Int] {
        collectionView.indexPathsForVisibleItems.map { $0.row % data.count }
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
        guard data.count > 1 else { return nil }
        
        let timer = GCDTimer(startImmediately: false, interval: .milliseconds(Int(interval * 1000))) { [weak self] timer in
            self?.scrollToNearestPage()
        }
        return timer
    }
    
    override func updateUIForStateChanged() {
        let size = cardLayoutSize.actualValue(withContainerSize: collectionView.frame.size)
        guard size.width > 0, size.height > 0, !data.isEmpty else { return }
        
        cardSize = size
        pageControl?.numberOfPages = data.count
        pageControl?.isHidden = data.count <= 1
        indexOfCurrentPage = loopMode == .circular && data.count > 1 ? data.count * halfMaxLoopCount : 0
        collectionView.reloadData()
        
        if case .automatic(let timeInterval) = scrollMode {
            timer = makeTimer(interval: timeInterval)
        } else {
            timer = nil
        }
        
        collectionView.performBatchUpdates(nil) { [weak self] _ in
            guard let self = self else { return }
            
            self.collectionView.contentOffset = self.caculateContentOffsetOfCollectionView(withPageIndex: self.indexOfCurrentPage)
            onCardChanged?(0)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loopMode == .circular && data.count > 1 ? data.count * halfMaxLoopCount * 2 : data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError()
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let onPrefetchItems {
            let indexPaths = indexPaths.map { IndexPath(row: $0.row % data.count, section: $0.section) }
            onPrefetchItems(indexPaths)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if let onCancelPrefetchingForItems {
            let indexPaths = indexPaths.map { IndexPath(row: $0.row % data.count, section: $0.section) }
            onCancelPrefetchingForItems(indexPaths)
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onCardSelected?(indexPath.row % data.count)
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
        
        var stride: CGFloat, progress: CGFloat
        switch loopMode {
        case .circular:
            var x: CGFloat = 0, y: CGFloat = 0
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                stride = cardSize.width + minimumLineSpacing
                x = scrollView.contentOffset.x.truncatingRemainder(dividingBy: (CGFloat(data.count) * stride))
                progress = x / stride
            case .bottomToTop, .topToBottom:
                stride = cardSize.height + minimumLineSpacing
                y = scrollView.contentOffset.y.truncatingRemainder(dividingBy: (CGFloat(data.count) * stride))
                progress = y / stride
            }
            
            onScroll?(CGPoint(x: x, y: y), roundProgressNearBounds(progress))
        default:
            switch scrollDirection {
            case .leftToRight, .rightToLeft:
                var firstStride = sideMargin + cardSize.width * 1.5 + minimumLineSpacing - frame.size.width / 2
                if case let .center(offset) = cardScrollStopAlignment.options {
                    firstStride -= offset
                } else if case let .head(offset) = cardScrollStopAlignment.options {
                    firstStride = sideMargin + cardSize.width + minimumLineSpacing - offset
                }
                stride = cardSize.width + minimumLineSpacing
                if data.count == 2 {
                    let lastPageOffset = 2 * sideMargin + stride * CGFloat(data.count) - minimumLineSpacing - frame.size.width
                    progress = scrollView.contentOffset.x / lastPageOffset
                } else {
                    progress = scrollView.contentOffset.x / firstStride
                    if progress > 1 {
                        progress = 1 + (scrollView.contentOffset.x - firstStride) / stride
                        if progress > CGFloat(data.count - 2) {
                            let anchorOffset = firstStride + CGFloat(data.count - 3) * stride
                            let offset = scrollView.contentOffset.x - anchorOffset
                            let total = 2 * sideMargin + stride * CGFloat(data.count) - minimumLineSpacing - frame.size.width - anchorOffset
                            progress = CGFloat(data.count - 2) + offset / total
                        }
                    }
                }
            case .topToBottom, .bottomToTop:
                var firstStride = sideMargin + cardSize.height * 1.5 + minimumLineSpacing - frame.size.height / 2
                if case let .center(offset) = cardScrollStopAlignment.options {
                    firstStride -= offset
                } else if case let .head(offset) = cardScrollStopAlignment.options {
                    firstStride = sideMargin + cardSize.height + minimumLineSpacing - offset
                }
                stride = cardSize.height + minimumLineSpacing
                if data.count == 2 {
                    let lastPageOffset = 2 * sideMargin + stride * CGFloat(data.count) - minimumLineSpacing - frame.size.height
                    progress = scrollView.contentOffset.y / lastPageOffset
                } else {
                    progress = scrollView.contentOffset.y / firstStride
                    if progress > 1 {
                        progress = 1 + (scrollView.contentOffset.y - firstStride) / stride
                        if progress > CGFloat(data.count - 2) {
                            let anchorOffset = firstStride + CGFloat(data.count - 3) * stride
                            let offset = scrollView.contentOffset.y - anchorOffset
                            let total = 2 * sideMargin + stride * CGFloat(data.count) - minimumLineSpacing - frame.size.height - anchorOffset
                            progress = CGFloat(data.count - 2) + offset / total
                        }
                    }
                }
            }
            
            onScroll?(scrollView.contentOffset, roundProgressNearBounds(progress))
        }
        
        if let pageControl = pageControl as? CardCarouselContinousPageControlType {
            print("roundProgressNearBounds(progress) \(roundProgressNearBounds(progress))")
            pageControl.progress = roundProgressNearBounds(progress)
        } else if let pageControl = pageControl as? CardCarouselNormalPageControlType {
            pageControl.currentPage = Int(roundProgressNearBounds(progress))
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer = nil
        indexAtBeginOfDragging = caculateIndexOfPage(withContentOffset: scrollView.contentOffset, slideDirection: .forward)
        contentOffsetAtBeginOfDragging = scrollView.contentOffset.x + scrollView.contentOffset.y
        
        onWillBeginDragging?(indexAtBeginOfDragging % data.count)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if case .automatic(let timeInterval) = scrollMode, loopMode != .single {
            timer = makeTimer(interval: timeInterval)
            timer?.resume()
        }
        
        let slideDirection = detectScrollDirection(withCurrentVelocity: velocity.x + velocity.y)
        guard !isCustomDecelerationRate else {
            let targetPageIndex = caculateIndexOfPage(withContentOffset: targetContentOffset.pointee, slideDirection: slideDirection)
            targetContentOffset.pointee = caculateContentOffsetOfCollectionView(withPageIndex: targetPageIndex)
            onWillEndDragging?(targetPageIndex % data.count)
            return
        }
        
        indexOfCurrentPage = caculateIndexOfPage(withContentOffset: scrollView.contentOffset, slideDirection: slideDirection)
        guard abs(velocity.x + velocity.y) > 0.35 && indexOfCurrentPage == indexAtBeginOfDragging else {
            targetContentOffset.pointee = caculateContentOffsetOfCollectionView(withPageIndex: indexOfCurrentPage)
            onWillEndDragging?(indexOfCurrentPage % data.count)
            return
        }
        
        // 修复 loopMode 为 rollback，用户在末尾向后拖动卡片，或在首部向前拖动卡片时 collection view 滚动过慢的问题
        let targetPageIndex = caculateIndexOfNearestPage(withSlideDirection: slideDirection)
        if loopMode == .rollback {
            if indexOfCurrentPage == data.count - 1, targetPageIndex == 0 {
                indexOfCurrentPage = targetPageIndex
                scrollView.setContentOffset(caculateContentOffsetOfCollectionView(withPageIndex: indexOfCurrentPage), animated: true)
            } else if indexOfCurrentPage == 0, targetPageIndex == data.count - 1 {
                
            } else {
                indexOfCurrentPage = targetPageIndex
                targetContentOffset.pointee = caculateContentOffsetOfCollectionView(withPageIndex: indexOfCurrentPage)
            }
        } else {
            targetContentOffset.pointee = caculateContentOffsetOfCollectionView(withPageIndex: indexOfCurrentPage)
        }
        
        onWillEndDragging?(indexOfCurrentPage % data.count)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        indexOfCurrentPage = caculateIndexOfPage(withContentOffset: collectionView!.contentOffset, slideDirection: .forward)
        if let pageControl = pageControl as? CardCarouselContinousPageControlType {
            pageControl.progress = CGFloat(indexOfCurrentPage % data.count)
        } else if let pageControl = pageControl as? CardCarouselNormalPageControlType {
            pageControl.currentPage = indexOfCurrentPage % data.count
        }
        onCardChanged?(indexOfCurrentPage % data.count)
        
        if case .automatic(let timeInterval) = scrollMode, loopMode != .single {
            timer = makeTimer(interval: timeInterval)
            timer?.resume()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleWhenScrollViewDidEndScrollingAnimation()
    }
}

private extension CardCarouselCore {
    func scrollToNearestPage() {
        let indexOfNearestPage = caculateIndexOfNearestPage(withSlideDirection: .forward)
        let contentOffset = caculateContentOffsetOfCollectionView(withPageIndex: indexOfNearestPage)
        if autoScrollAnimationOptions.duration <= 0 {
            collectionView.setContentOffset(contentOffset, animated: true)
        } else {
            collectionView.setContentOffset(
                contentOffset, duration: autoScrollAnimationOptions.duration,
                timingFunction: autoScrollAnimationOptions.timingFunction
            ) { [weak self] in
                self?.handleWhenScrollViewDidEndScrollingAnimation()
            }
        }
    }
    
    func handleWhenScrollViewDidEndScrollingAnimation() {
        guard !data.isEmpty else { return }
        
        indexOfCurrentPage = caculateIndexOfPage(withContentOffset: collectionView.contentOffset, slideDirection: .forward)
        if let pageControl = pageControl as? CardCarouselContinousPageControlType {
            pageControl.progress = CGFloat(indexOfCurrentPage % data.count)
        } else if let pageControl = pageControl as? CardCarouselNormalPageControlType {
            pageControl.currentPage = indexOfCurrentPage % data.count
        }
        onCardChanged?(indexOfCurrentPage % data.count)
        
        if loopMode == .single && indexOfCurrentPage == data.count - 1 {
            timer = nil
        } else if loopMode == .circular && indexOfCurrentPage % data.count == 0 {
            indexOfCurrentPage = data.count * halfMaxLoopCount
            collectionView!.contentOffset = caculateContentOffsetOfCollectionView(withPageIndex: indexOfCurrentPage)
        }
    }
    
    func detectScrollDirection(withCurrentVelocity velocity: CGFloat) -> SlideDirection {
        var slideDirection: SlideDirection
        if velocity == 0 {
            if contentOffsetAtBeginOfDragging >= collectionView.contentOffset.x + collectionView.contentOffset.y {
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
    
    func caculateIndexOfNearestPage(withSlideDirection slideDirection: SlideDirection) -> Int {
        var indexOfNearestPage = 0
        switch slideDirection {
        case .forward:
            if indexOfCurrentPage % data.count == data.count - 1 {
                switch loopMode {
                case .circular:
                    indexOfNearestPage = indexOfCurrentPage + 1
                case .rollback:
                    indexOfNearestPage = 0
                case .single:
                    indexOfNearestPage = data.count - 1
                }
            } else {
                indexOfNearestPage = indexOfCurrentPage + 1
            }
        case .backward:
            if indexOfCurrentPage % data.count == 0 {
                switch loopMode {
                case .circular:
                    indexOfNearestPage = indexOfCurrentPage - 1
                case .rollback:
                    indexOfNearestPage = data.count - 1
                case .single:
                    indexOfNearestPage = 0
                }
            } else {
                indexOfNearestPage = indexOfCurrentPage - 1
            }
        }
        
        return indexOfNearestPage
    }
    
    func caculateIndexOfPage(withContentOffset offset: CGPoint, slideDirection: SlideDirection) -> Int {
        var delta: CGFloat
        switch loopMode {
        case .circular:
            delta = 0
        default:
            var anchorOffset: CGFloat
            switch cardScrollStopAlignment.options {
            case let .center(offset):
                anchorOffset = offset
            case let .head(offset):
                anchorOffset = offset
            }
            
            delta = sideMargin - anchorOffset
        }
        
        var indexOfCurrentPage: Int
        switch scrollDirection {
        case .rightToLeft, .leftToRight:
            if abs(collectionView.contentSize.width - offset.x - collectionView.bounds.width) < 1 {
                indexOfCurrentPage = data.count - 1
            } else {
                let stepLength = cardSize.width + minimumLineSpacing
                indexOfCurrentPage = caculateIndexOfPage(withContentOffset: offset.x - delta, stepLength: stepLength, slideDirection: slideDirection)
            }
        case .bottomToTop, .topToBottom:
            if abs(collectionView.contentSize.height - offset.y - collectionView.bounds.height) < 1 {
                indexOfCurrentPage = data.count - 1
            } else {
                let stepLength = cardSize.height + minimumLineSpacing
                indexOfCurrentPage = caculateIndexOfPage(withContentOffset: offset.y - delta, stepLength: stepLength, slideDirection: slideDirection)
            }
        }
        
        return indexOfCurrentPage
    }
    
    func caculateIndexOfPage(withContentOffset offset: CGFloat, stepLength: CGFloat, slideDirection: SlideDirection) -> Int {
        let quotient = offset / stepLength
        var targetIndex = floor(quotient)
        let delta = quotient - targetIndex
        if delta * stepLength < 1 {
            return min(Int(targetIndex), collectionView.numberOfItems(inSection: 0))
        } else if stepLength - delta * stepLength < 1 {
            return min(Int(targetIndex + 1), collectionView.numberOfItems(inSection: 0))
        } else {
            var threshold: CGFloat
            switch cardPagingThreshold {
            case .fractional(let ratio):
                switch scrollDirection {
                case .rightToLeft, .leftToRight:
                    threshold = ratio * cardSize.width
                case .bottomToTop, .topToBottom:
                    threshold = ratio * cardSize.height
                }
            case .absolute(let value):
                threshold = value
            }
            
            switch slideDirection {
            case .forward:
                if delta * stepLength > threshold {
                    targetIndex += 1
                }
            case .backward:
                if stepLength - delta * stepLength < threshold {
                    targetIndex += 1
                }
            }
            return min(Int(targetIndex), collectionView.numberOfItems(inSection: 0))
        }
    }
    
    func caculateContentOffsetOfCollectionView(withPageIndex index: Int) -> CGPoint {
        var contentOffset: CGPoint = .zero
        if index == 0 {
            if data.count == 1 {
                switch scrollDirection {
                case .rightToLeft, .leftToRight:
                    switch singleCardAlignment.options {
                    case let .center(offset):
                        contentOffset.x -= offset
                    case let .head(offset):
                        contentOffset.x = (collectionView.bounds.width - cardSize.width) / 2 - offset
                    }
                case .bottomToTop, .topToBottom:
                    switch singleCardAlignment.options {
                    case let .center(offset):
                        contentOffset.y -= offset
                    case let .head(offset):
                        contentOffset.y = (collectionView.bounds.height - cardSize.height) / 2 - offset
                    }
                }
            }
        } else if loopMode != .circular && index == data.count - 1 {
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                contentOffset.x = collectionView.contentSize.width - bounds.width
            case .bottomToTop, .topToBottom:
                contentOffset.y = collectionView.contentSize.height - bounds.height
            }
        } else {
            var delta: CGFloat = 0
            switch loopMode {
            case .circular:
                delta = 0
            default:
                switch cardScrollStopAlignment.options {
                case let .center(offset):
                    switch scrollDirection {
                    case .rightToLeft, .leftToRight:
                        delta = sideMargin + (cardSize.width - collectionView.bounds.width) / 2 - offset
                    case .bottomToTop, .topToBottom:
                        delta = sideMargin + (cardSize.height - collectionView.bounds.height) / 2 - offset
                    }
                case let .head(offset):
                    delta = sideMargin - offset
                }
            }
            
            switch scrollDirection {
            case .rightToLeft, .leftToRight:
                let stepLength = cardSize.width + minimumLineSpacing
                contentOffset.x = stepLength * CGFloat(index) + delta
            case .bottomToTop, .topToBottom:
                let stepLength = cardSize.height + minimumLineSpacing
                contentOffset.y = stepLength * CGFloat(index) + delta
            }
        }
        
        return contentOffset
    }
}

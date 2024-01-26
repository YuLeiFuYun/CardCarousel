//
//  CardCarouselBaseView.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

@dynamicMemberLookup
public class CardCarouselBaseView: UIView {
    
    var backgroundView: UIView? {
        didSet {
            guard let backgroundView else { return }
            
            backgroundView.frame = bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(backgroundView, belowSubview: collectionView)
        }
    }
    
    var cardCornerRadius: CGFloat = 0
    
    var cardMaskedCorners: CACornerMask = []
    
    var cardBorderWidth: CGFloat = 0
    
    var cardBorderColor: CGColor?
    
    var cardShadowOffset: CGSize = .zero
    
    var cardShadowColor: CGColor?
    
    var cardShadowRadius: CGFloat = 0
    
    var cardShadowOpacity: Float = 0
    
    var cardShadowPath: CGPath?
    /// 滑动方向两侧的边距
    var sideMargin: CGFloat = 0
    /// 卡片最小间距
    var minimumLineSpacing: CGFloat = 0 {
        didSet {
            if let flowLayout = collectionView.collectionViewLayout as? CardTransformLayout {
                flowLayout.minimumLineSpacing = minimumLineSpacing
            }
        }
    }
    /// 当前卡片是否始终在最前面
    var disableCurrentCardAlwaysOnTop = false {
        didSet {
            if let flowLayout = collectionView.collectionViewLayout as? CardTransformLayout {
                flowLayout.disableCurrentCardAlwaysOnTop = disableCurrentCardAlwaysOnTop
            }
        }
    }
    /// 是否禁用用户滑动
    var disableUserSwipe = false {
        didSet {
            collectionView.isScrollEnabled = !disableUserSwipe
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
        }
    }
    /// 是否允许反弹
    var disableBounce = false {
        didSet {
            collectionView.bounces = !disableBounce
        }
    }
    /// 使用默认 cell 加载网络图片时，是否禁用下采样
    var disableDownsampling = false
    /// 卡片布局尺寸
    var cardLayoutSize: CardLayoutSize = .init() {
        didSet {
            guard collectionView.frame != .zero else { return }
            cardSize = cardLayoutSize.actualValue(withContainerSize: collectionView.frame.size)
        }
    }
    /// 单卡片时的对齐方式
    var singleCardAlignment: CardScrollStopAlignment = .center
    /// 滑动停止时的对齐方式
    var cardScrollStopAlignment: CardScrollStopAlignment = .center {
        didSet {
            if let flowLayout = collectionView.collectionViewLayout as? CardTransformLayout {
                flowLayout.cardScrollStopAlignment = cardScrollStopAlignment
            }
        }
    }
    /// 滚动方向
    var scrollDirection: CardScrollDirection = .leftToRight {
        didSet {
            updateLayoutAfterScrollDirectionChanged()
        }
    }
    /// 卡片变换模式
    var cardTransformMode: CardTransformMode = .none {
        didSet {
            if let flowLayout = collectionView.collectionViewLayout as? CardTransformLayout {
                flowLayout.cardTransformMode = cardTransformMode
            }
        }
    }
    /// 自动滚动还是手动滚动
    var scrollMode: CardScrollMode = .automatic(timeInterval: 3) {
        didSet {
            if case .automatic(let timeInterval) = scrollMode {
                timer = makeTimer(interval: timeInterval)
            } else {
                timer = nil
            }
        }
    }
    /// 自动滚动时的滚动动画效果
    var autoScrollAnimationOptions: CardScrollAnimationOptions = .system
    /// 循环模式
    var loopMode: CardLoopMode = .circular {
        didSet {
            updateUIForStateChanged()
        }
    }
    /// 卡片分页阈值
    var cardPagingThreshold: CardPagingThreshold = .fractional(0.5)
    /// 是否对 decelerationRate 进行了自定义
    var isCustomDecelerationRate = false
    /// 一个浮点值，用于确定用户抬起手指后的减速率，值越大抬起手之后滑得越远
    var decelerationRate: CGFloat = 0.9924 {
        didSet { isCustomDecelerationRate = true }
    }
    /// 卡片尺寸
    var cardSize: CGSize = .zero {
        didSet {
            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout, cardSize.width > 0, cardSize.height > 0 {
                flowLayout.itemSize = cardSize
            }
        }
    }
    /// 使用默认卡片时的占位图
    var placeholder: UIImage?
    
    var pageControl: CardCarouselPageControlType?
    
    var makePageControl: (() -> CardCarouselPageControlType)? {
        didSet {
            guard let makePageControl else { return }
            pageControl = makePageControl()
            pageControl?.semanticContentAttribute = .forceLeftToRight
            pageControl?.translatesAutoresizingMaskIntoConstraints = false
            addSubview(pageControl!)
        }
    }
    
    var pageControlPosition: PageControlPosition = .centerXBottom {
        didSet {
            setPageControlScrollDirectionIfNeeded()
            setPageControlLayoutConstraints()
        }
    }
    
    /// 预取
    var onPrefetchItems: (([IndexPath]) -> Void)?
    /// 取消预取
    var onCancelPrefetchingForItems: (([IndexPath]) -> Void)?
    /// 卡片被点击
    var onCardSelected: ((Int) -> Void)?
    /// 卡片滚动时被调用
    var onScroll: ((CGPoint, CGFloat) -> Void)?
    /// 用户拖动将开始时被调用
    var onWillBeginDragging: ((Int) -> Void)?
    /// 用户拖动将结束时被调用
    var onWillEndDragging: ((Int) -> Void)?
    /// 卡片切换时被调用
    var onCardChanged: ((Int) -> Void)?
    
    var timer: GCDTimer?
    
    var collectionView: UICollectionView!
    
    public var visibleCards: [UICollectionViewCell] {
        collectionView.visibleCells
    }
    
    public var indicesForVisiblePages: [Int] {
        fatalError()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView = makeCollectionView(frame: frame)
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        updateUIForStateChanged()
    }
    
    func makeTimer(interval: TimeInterval) -> GCDTimer? {
        fatalError()
    }
    
    func updateUIForStateChanged() {
        fatalError()
    }
    
    public subscript<Item>(dynamicMember keyPath: WritableKeyPath<CardCarouselCore<Item>, [Item]>) -> [Item] {
        get {
            if let view = self as? CardCarouselCore<Item> {
                return view[keyPath: keyPath]
            }
            fatalError()
        }
        set {
            if let view = self as? CardCarouselCore<CardCarouselDataRepresentable> {
                if Item.self == String.self {
                    view.data = newValue as! [String]
                } else if Item.self == UIImage.self {
                    view.data = newValue as! [UIImage]
                }
            } else if var view = self as? CardCarouselCore<Item> {
                view[keyPath: keyPath] = newValue
            }
        }
    }
}

private extension CardCarouselBaseView {
    func makeCollectionView(frame: CGRect) -> UICollectionView {
        let collectionView = UICollectionView(frame: CGRect(origin: .zero, size: frame.size), collectionViewLayout: CardTransformLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = .init(rawValue: decelerationRate)
        collectionView.semanticContentAttribute = .forceLeftToRight
        
        return collectionView
    }
    
    func updateLayoutAfterScrollDirectionChanged() {
        // 重新创建 CardTransformLayout 以解决 scrollDirection 变为 rightToLeft 时布局混乱的问题
        let transformLayout = CardTransformLayout(cardScrollDirection: scrollDirection)
        transformLayout.cardScrollStopAlignment = cardScrollStopAlignment
        transformLayout.cardTransformMode = cardTransformMode
        transformLayout.disableCurrentCardAlwaysOnTop = disableCurrentCardAlwaysOnTop
        transformLayout.minimumLineSpacing = minimumLineSpacing
        if cardSize.width > 0, cardSize.height > 0 { transformLayout.itemSize = cardSize }
        collectionView.collectionViewLayout = transformLayout
        
        setPageControlScrollDirectionIfNeeded()
        switch scrollDirection {
        case .leftToRight:
            collectionView.semanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            collectionView.semanticContentAttribute = .forceRightToLeft
        case .bottomToTop:
            collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        default:
            break
        }
    }
    
    func setPageControlScrollDirectionIfNeeded() {
        guard let pageControl else { return }
        
        switch scrollDirection {
        case .leftToRight:
            pageControl.semanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            pageControl.semanticContentAttribute = .forceRightToLeft
        case .topToBottom, .bottomToTop:
            if let pageControl = pageControl as? UIPageControl {
                if #available(iOS 16, *) {
                    pageControl.direction = .init(rawValue: scrollDirection.rawValue) ?? .topToBottom
                } else {
                    if scrollDirection == .topToBottom {
                        pageControl.transform = CGAffineTransform(rotationAngle: .pi / 2)
                    } else {
                        pageControl.transform = CGAffineTransform(rotationAngle: -.pi / 2)
                    }
                }
            }
        }
    }
    
    func setPageControlLayoutConstraints() {
        guard let pageControl else { return }
        
        switch pageControlPosition.options {
        case .leftTop:
            NSLayoutConstraint.activate([
                pageControl.leftAnchor.constraint(equalTo: leftAnchor, constant: pageControlPosition.offset.x),
                pageControl.topAnchor.constraint(equalTo: topAnchor, constant: pageControlPosition.offset.y)
            ])
        case .rightTop:
            NSLayoutConstraint.activate([
                pageControl.rightAnchor.constraint(equalTo: rightAnchor, constant: pageControlPosition.offset.x),
                pageControl.topAnchor.constraint(equalTo: topAnchor, constant: pageControlPosition.offset.y)
            ])
        case .leftBottom:
            NSLayoutConstraint.activate([
                pageControl.leftAnchor.constraint(equalTo: leftAnchor, constant: pageControlPosition.offset.x),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: pageControlPosition.offset.y)
            ])
        case .rightBottom:
            NSLayoutConstraint.activate([
                pageControl.rightAnchor.constraint(equalTo: rightAnchor, constant: pageControlPosition.offset.x),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: pageControlPosition.offset.y)
            ])
        case .centerXTop:
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: centerXAnchor, constant: pageControlPosition.offset.x),
                pageControl.topAnchor.constraint(equalTo: topAnchor, constant: pageControlPosition.offset.y)
            ])
        case .centerXBottom:
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: centerXAnchor, constant: pageControlPosition.offset.x),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: pageControlPosition.offset.y)
            ])
        case .leftCenterY:
            if #available(iOS 16, *) {
                NSLayoutConstraint.activate([
                    pageControl.leftAnchor.constraint(equalTo: leftAnchor, constant: pageControlPosition.offset.x),
                    pageControl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: pageControlPosition.offset.y)
                ])
            } else {
                NSLayoutConstraint.activate([
                    pageControl.centerXAnchor.constraint(equalTo: leftAnchor, constant: pageControlPosition.offset.x + 15),
                    pageControl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: pageControlPosition.offset.y)
                ])
            }
            
        case .rightCenterY:
            if #available(iOS 16, *) {
                NSLayoutConstraint.activate([
                    pageControl.rightAnchor.constraint(equalTo: rightAnchor, constant: pageControlPosition.offset.x),
                    pageControl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: pageControlPosition.offset.y)
                ])
            } else {
                NSLayoutConstraint.activate([
                    pageControl.centerXAnchor.constraint(equalTo: rightAnchor, constant: pageControlPosition.offset.x - 15),
                    pageControl.centerYAnchor.constraint(equalTo: centerYAnchor, constant: pageControlPosition.offset.y)
                ])
            }
        }
    }
}

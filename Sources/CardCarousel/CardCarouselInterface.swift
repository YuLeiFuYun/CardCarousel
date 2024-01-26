//
//  CardCarouselInterface.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

public protocol CardCarouselInterface {
    /// 卡片布局尺寸，默认铺满 super view
    ///
    /// 动物协鸣：汪；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    /// widthDimension：咕；heightDimension：嗡
    /// fractionalWidth：呦；fractionalHeight：呜；absolute：嗷；inset：嘤
    ///
    /// 高级动物：矛盾；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    /// widthDimension：自私；heightDimension：无聊
    /// fractionalWidth：好色；fractionalHeight：善良；absolute：博爱；inset：诡辩
    ///
    /// 催妆曲：醒呀；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    /// widthDimension：画眉在杏枝上歌；heightDimension：远峰尖滴着新黛
    /// fractionalWidth：画眉人不起是因何；fractionalHeight：正好蘸来描画双蛾；absolute：春莺儿衔了额黄归；inset：起呀
    func cardLayoutSize(widthDimension: CardLayoutDimension, heightDimension: CardLayoutDimension) -> Self
    
    /// 卡片最小间距，默认 0
    ///
    /// 动物协鸣：啾；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    ///
    /// 高级动物：虚伪；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    ///
    /// 催妆曲：从睡乡醒回；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    func minimumLineSpacing(_ spacing: CGFloat) -> Self
    
    /// 卡片变换模式，默认 .none
    ///
    /// 动物协鸣：喵；liner：呜；coverflow：嗷
    ///
    /// 高级动物：贪婪；liner：真诚；coverflow：金钱
    ///
    /// 催妆曲：晨鸡声呖呖在相催；liner：日神也捧着金镜；coverflow：等候你起来梳早妆
    func cardTransformMode(_ mode: CardTransformMode) -> Self
    
    /// 默认当前卡片始终在最前面，调用此方法，当前卡片可能会被其他卡片遮挡。
    ///
    /// 动物协鸣：咩
    ///
    /// 高级动物：欺骗
    ///
    /// 催妆曲：看呀
    func disableCurrentCardAlwaysOnTop() -> Self
    
    /// 滑动方向两侧的边距，loopMode 非 circular 时才会生效。默认 0
    ///
    /// 动物协鸣：哞；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    ///
    /// 高级动物：幻想；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    ///
    /// 催妆曲：霞织的五彩衣裳；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    func sideMargin(_ margin: CGFloat) -> Self
    
    /// 滑动停止时的卡片对齐方式，默认中心对齐
    ///
    /// 动物协鸣：呱；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    /// center：咕；head：嗡
    ///
    /// 高级动物：疑惑；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    /// center：地狱；head：天堂
    ///
    /// 催妆曲：趁草际珠垂；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    /// center：画眉在杏枝上歌；head：画眉人不起是因何
    func scrollStopAlignment(_ alignment: CardScrollStopAlignment) -> Self
    
    /// 单卡片时的对齐方式，默认中心对齐
    ///
    /// 动物协鸣：呦；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    /// center：咕；head：嗡
    ///
    /// 高级动物：简单；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    /// center：地狱；head：天堂
    ///
    /// 催妆曲：春莺儿衔了额黄归；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    /// center：画眉在杏枝上歌；head：画眉人不起是因何
    func singleCardAlignment(_ alignment: CardScrollStopAlignment) -> Self
    
    /// 滚动方向，默认 .leftToRight
    ///
    /// 动物协鸣：呜
    /// leftToRight：汪；rightToLeft：啾；topToBottom：喵；bottomToTop：咩
    ///
    /// 高级动物：善变
    /// leftToRight：辉煌；rightToLeft：暗淡；topToBottom：得意；bottomToTop：伤感
    ///
    /// 催妆曲：画眉在杏枝上歌
    /// leftToRight：杨柳的丝发飘扬；rightToLeft：她对着如镜的池塘；topToBottom：百花是薰沐已毕；bottomToTop：她们身上喷出芬芳
    func scrollDirection(_ direction: CardScrollDirection) -> Self
    
    /// 自动滚动时的滚动动画效果，默认 .system
    func autoScrollAnimation(_ animationOptions: CardScrollAnimationOptions) -> Self
    
    /// 自动滚动还是手动滚动，默认 .automatic(timeInterval: 3)
    ///
    /// 动物协鸣：嗡；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    /// automatic：咕；manual：嗡
    ///
    /// 高级动物：好强；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    /// automatic：怀恨；manual：报复
    ///
    /// 催妆曲：画眉人不起是因何；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    /// automatic：远峰尖滴着新黛；manual：正好蘸来描画双蛾
    ///
    /// 注意：用咒语调用时时间间隔只能设为整数！
    func scrollMode(_ mode: CardScrollMode) -> Self
    
    /// 循环模式，默认 circular
    ///
    /// 动物协鸣：嘎
    /// circular：汪；rollback：啾；single：喵
    ///
    /// 高级动物：无奈
    /// circular：争夺；rollback：埋怨；single：冒险
    ///
    /// 催妆曲：远峰尖滴着新黛
    /// circular：趁草际珠垂；rollback：春莺儿衔了额黄归；single：赶快拿妆梳理好
    func loopMode(_ mode: CardLoopMode) -> Self
    
    /// 卡片分页阈值，默认卡片宽度的一半
    ///
    /// 动物协鸣：叽；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    /// fractional：咕；absolute：嗡
    ///
    /// 高级动物：孤独；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    /// fractional：伟大；absolute：渺小
    ///
    /// 催妆曲：正好蘸来描画双蛾；0-9：["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    /// fractional：画眉在杏枝上歌；absolute：画眉人不起是因何
    func pagingThreshold(_ pagingThreshold: CardPagingThreshold) -> Self
    
    /// 一个浮点值，用于确定用户抬起手指后的减速率，值越大抬起手之后滑得越远，loopMode 为 rollback 时设置无效，默认值为 0.9924
    ///
    /// 动物协鸣：吱；0-9：["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
    ///
    /// 高级动物：脆弱；0-9：["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
    ///
    /// 催妆曲：杨柳的丝发飘扬；["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
    func decelerationRate(_ value: CGFloat) -> Self
    
    /// 禁止用户滑动
    ///
    /// 动物协鸣：嘶
    ///
    /// 高级动物：忍让
    ///
    /// 催妆曲：她对着如镜的池塘
    func disableUserSwipe() -> Self
    
    /// 使用默认 cell 加载网络图片时，默认启用下采样，调用此方法禁用下采样
    ///
    /// 动物协鸣：咕
    ///
    /// 高级动物：气愤
    ///
    /// 催妆曲：百花是薰沐已毕
    func disableDownsampling() -> Self
    
    /// 设置 backgroundView
    func backgroundView(_ view: UIView) -> Self
    
    /// 卡片圆角设置
    ///
    /// 动物协鸣：嗷，不支持 maskedCorners 设置
    ///
    /// 高级动物：复杂，不支持 maskedCorners 设置
    ///
    /// 催妆曲：她们身上喷出芬芳，不支持 maskedCorners 设置
    func cardCornerRadius(_ value: CGFloat, maskedCorners: CACornerMask) -> Self
    
    /// 禁用反弹效果
    func disableBounce() -> Self
    
    /// 设置边框宽度及颜色
    func border(width: CGFloat, color: CGColor?) -> Self
    
    /// 设置使用默认卡片时的占位图
    func placeholder(_ image: UIImage) -> Self
    
    /// 阴影相关
    func shadow(offset: CGSize, color: CGColor?, radius: CGFloat, opacity: Float, path: CGPath?) -> Self
    
    /// 设置 page control
    func pageControl(makePageControl: @escaping () -> CardCarouselPageControlType, position: PageControlPosition) -> Self
    
    /// 卡片被点击时调用
    func onCardSelected(_ handler: @escaping (_ index: Int) -> Void) -> Self
    
    /// 卡片滚动时调用
    func onScroll(_ handler: @escaping (_ offset: CGPoint, _ progress: CGFloat) -> Void) -> Self
    
    /// 卡片切换时调用
    func onCardChanged(_ handler: @escaping (_ index: Int) -> Void) -> Self
    
    /// 开始拖动卡片时调用
    func onWillBeginDragging(_ handler: @escaping (_ index: Int) -> Void) -> Self
    
    /// 结束拖动卡片时调用
    func onWillEndDragging(_ handler: @escaping (_ index: Int) -> Void) -> Self
    
    /// 数据预取
    func onPrefetchItems(_ handler: @escaping (_ indexs: [IndexPath]) -> Void) -> Self
    
    /// 取消预取
    func onCancelPrefetchItems(_ handler: @escaping (_ indexs: [IndexPath]) -> Void) -> Self
}

protocol CardCarouselInternalType {
    var cardCarouselView: CardCarouselBaseView { get set }
}

public extension CardCarouselInterface {
    func cardLayoutSize(
        widthDimension: CardLayoutDimension = .fractionalWidth(1),
        heightDimension: CardLayoutDimension = .fractionalHeight(1)
    ) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardLayoutSize = .init(widthDimension: widthDimension, heightDimension: heightDimension)
        }
        
        return self
    }
    
    func minimumLineSpacing(_ spacing: CGFloat) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.minimumLineSpacing = spacing
        }
        
        return self
    }
    
    func cardTransformMode(_ mode: CardTransformMode) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardTransformMode = mode
        }
        
        return self
    }
    
    func disableCurrentCardAlwaysOnTop() -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.disableCurrentCardAlwaysOnTop = true
        }
        
        return self
    }
    
    func sideMargin(_ margin: CGFloat) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.sideMargin = margin
        }
        
        return self
    }
    
    func scrollStopAlignment(_ alignment: CardScrollStopAlignment) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardScrollStopAlignment = alignment
        }
        
        return self
    }
    
    func singleCardAlignment(_ alignment: CardScrollStopAlignment) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.singleCardAlignment = alignment
        }
        
        return self
    }
    
    func scrollDirection(_ direction: CardScrollDirection) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.scrollDirection = direction
        }
        
        return self
    }
    
    func autoScrollAnimation(_ animationOptions: CardScrollAnimationOptions) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.autoScrollAnimationOptions = animationOptions
        }
        
        return self
    }
    
    func scrollMode(_ mode: CardScrollMode) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.scrollMode = mode
        }
        
        return self
    }
    
    func loopMode(_ mode: CardLoopMode) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.loopMode = mode
        }
        
        return self
    }
    
    func pagingThreshold(_ pagingThreshold: CardPagingThreshold) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardPagingThreshold = pagingThreshold
        }
        
        return self
    }
    
    func decelerationRate(_ value: CGFloat) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.decelerationRate = value
        }
        
        return self
    }
    
    func disableUserSwipe() -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.disableUserSwipe = true
        }
        
        return self
    }
    
    func disableDownsampling() -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.disableDownsampling = true
        }
        
        return self
    }
    
    func backgroundView(_ view: UIView) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.backgroundView = view
        }
        
        return self
    }
    
    func cardCornerRadius(_ value: CGFloat, maskedCorners: CACornerMask = []) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardCornerRadius = value
            cardCarousel.cardCarouselView.cardMaskedCorners = maskedCorners
        }
        
        return self
    }
    
    func disableBounce() -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.disableBounce = true
        }
        
        return self
    }
    
    func border(width: CGFloat, color: CGColor?) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardBorderWidth = width
            cardCarousel.cardCarouselView.cardBorderColor = color
        }
        
        return self
    }
    
    func placeholder(_ image: UIImage) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.placeholder = image
        }
        
        return self
    }
    
    func shadow(offset: CGSize = .zero, color: CGColor? = nil, radius: CGFloat = 0, opacity: Float = 0, path: CGPath? = nil) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.cardShadowOffset = offset
            cardCarousel.cardCarouselView.cardShadowColor = color
            cardCarousel.cardCarouselView.cardShadowRadius = radius
            cardCarousel.cardCarouselView.cardShadowOpacity = opacity
            cardCarousel.cardCarouselView.cardShadowPath = path
        }
        
        return self
    }
    
    func pageControl(makePageControl: @escaping () -> CardCarouselPageControlType, position: PageControlPosition) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.makePageControl = makePageControl
            cardCarousel.cardCarouselView.pageControlPosition = position
        }
        
        return self
    }
    
    func onCardSelected(_ handler: @escaping (_ index: Int) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onCardSelected = handler
        }
        
        return self
    }
    
    func onScroll(_ handler: @escaping (_ offset: CGPoint, _ progress: CGFloat) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onScroll = handler
        }
        
        return self
    }
    
    func onCardChanged(_ handler: @escaping (_ index: Int) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onCardChanged = handler
        }
        
        return self
    }
    
    func onWillBeginDragging(_ handler: @escaping (_ index: Int) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onWillBeginDragging = handler
        }
        
        return self
    }
    
    func onWillEndDragging(_ handler: @escaping (_ index: Int) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onWillEndDragging = handler
        }
        
        return self
    }
    
    func onPrefetchItems(_ handler: @escaping (_ indexs: [IndexPath]) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onPrefetchItems = handler
        }
        
        return self
    }
    
    func onCancelPrefetchItems(_ handler: @escaping (_ indexs: [IndexPath]) -> Void) -> Self {
        if let cardCarousel = self as? CardCarouselInternalType {
            cardCarousel.cardCarouselView.onCancelPrefetchingForItems = handler
        }
        
        return self
    }
}

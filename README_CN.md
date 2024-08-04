## CardCarousel

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=Swift&logoColor=white&style=for-the-badge)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/badge/platform-iOS%2012%2B-%238D6748.svg?style=for-the-badge)](https://www.apple.com/nl/ios/)
[![Release](https://img.shields.io/cocoapods/v/CardCarousel.svg?style=for-the-badge)](https://cocoapods.org/?q=CardCarousel)
[![SPM](https://img.shields.io/badge/SPM-✔-4BC51D.svg?style=for-the-badge)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/license-mit-%23d9ead3.svg?style=for-the-badge)](./LICENSE)

`CardCarousel` 是一个功能强大、使用简单的轮播组件，你甚至可以使用咒语进行设置。



## 特性

- [x] 支持方法链式调用

- [x] 支持类似 `NSCollectionLayoutSize` 的方式设置页面尺寸

- [x] 支持多种循环模式

- [x] 支持设置滚动停止时的页面对齐方式

- [x] 支持设置滚动方向

- [x] 支持设置自动滚动时的滚动动画效果

- [x] 支持设置页面切换效果

- [x] 支持设置分页阈值

- [x] 支持设置滑动时的页面减速速率

- [x] 支持 `SwiftUI`

- [x] 支持通过咒语进行设置

- [x] 更多...



## 安装

### Swift Package Manager

在 Xcode， 选择 `File` > `Add Package Dependencies...` ， 粘贴 `https://github.com/YuLeiFuYun/CardCarousel.git` 。

### CocoaPods

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'CardCarousel', '~> 2.0'
end
```



## 环境要求

- iOS 12+
- Swift 5.9+
- Xcode 15+



## 使用

### In UIKit

- 简单使用：

```swift
import CardCarousel

let cardCarousel = CardCarousel(frame: ...).add(to: view)

// 对于本地图像，可以直接分配一个 UIImage 对象数组。
cardCarousel.items = [UIImage]

// 在 CardCarousel 中使用远程图像之前，请使用适当的加载、预取和取消行为设置图像加载管理器（ImageLoadingManager）。这通常需要使用第三方库（如 SDWebImage 或 Kingfisher）来完成。
// 下面是一个如何配置 ImageLoadingManager 的示例：
import Kingfisher

ImageLoadingManager.shared.configure { url, imageView, placeholder, completion in
    imageView.kf.setImage(with: url, placeholder: placeholder) { _ in
        completion()
    }
} prefetch: { urls in
    ImagePrefetcher(urls: urls).start()
} cancel: { urls in
    ImagePrefetcher(urls: urls).stop()
}

// 配置 ImageLoadingManager 后，可以将 CardCarousel 的 items 设置为 URL 字符串数组：
cardCarousel.items = [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg",
    "https://example.com/image3.jpg"
]
```


![The IT Crowd](./Assets/The_IT_Crowd.gif)



- 自定义 cell：

```swift
CardCarousel(items: items) { (cell: CustomCell, index: Int, itemIdentifier: Item) in
    cell.imageView.kf.setImage(with: url)
    cell.indexLabel.backgroundColor = itemIdentifier.color
    cell.indexLabel.text = itemIdentifier.index
}
.cardLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(0.7))
.cardTransformMode(.liner(minimumAlpha: 0.3))
.cardCornerRadius(10)
.add(to: view, layoutConstraints: { cardCarouselView, superView in
    NSLayoutConstraint.activate([
        cardCarouselView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
        cardCarouselView.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
        cardCarouselView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 100),
        cardCarouselView.heightAnchor.constraint(equalToConstant: 200)
    ])
})
```


![罗小黑战记](./Assets/罗小黑战记.gif)



- 使用 SwiftUI View：

```swift
CardCarousel(items: items) { index, itemIdentifier in
    HStack {
        Text(itemIdentifier)
            .font(.system(size: 18))
        Spacer()
    }
}
.scrollDirection(.topToBottom)
.add(to: view)
```

![道与碳基猴子饲养守则](./Assets/道与碳基猴子饲养守则.gif)



- 自定义 page control：

```swift
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
```

示例：

```swift
extension CustomPageControl: CardCarouselContinousPageControlType {
    ...
}

CardCarousel(itemsPublisher: $items) { index, itemIdentifier in
    Text(itemIdentifier.text)
        .font(.title)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(itemIdentifier.color)
}
.cardLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200))
.minimumLineSpacing(20)
.scrollStopAlignment(.head(offset: 10))
.pageControl(makePageControl: {
    let pageControl = CustomPageControl()
    pageControl.currentPageTintColor = .white
    pageControl.tintColor = .green
    pageControl.radius = 4
    pageControl.padding = 15
    return pageControl
}, position: .centerXBottom(offset: CGPoint(x: 0, y: -10)))
.add(to: view)
```

![The_Stormlight_Archive](./Assets/The_Stormlight_Archive.gif)



### In SwiftUI

```swift
struct Content: View {
    @State var items = [
        "飞光飞光 劝尔一杯酒",
        "吾不识青天高 黄地厚",
        "惟见月寒日暖 来煎人寿",
        "食熊则肥 食蛙则瘦",
    ]
    
    
    var body: some View {
        CardCarouselView($items, content: { index, itemIdentifier in
            if index.isMultiple(of: 2) {
                ZStack {
                    Color.blue
                    Text(itemIdentifier)
                }
            } else {
                Text(itemIdentifier)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.yellow)
                    .clipShape(Capsule())
            }
        })
      	.scrollMode(.automatic(timeInterval: 3))
        .cardTransformMode(.coverflow(minimumAlpha: 0.3))
        .cardLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(0.7))
        .minimumLineSpacing(-20)
        .cardCornerRadius(10)
        // 该值越大，用户释放拖拽后滑动的距离越远，默认值为 0.9924。
        .decelerationRate(0.999)
        .onCardSelected({ index in
            print(index)
        })
        .onCardChanged({ index in
            print(index)
        })
        .frame(height: 200)
    }
}
```

![昼苦短](./Assets/昼苦短.gif)



### 咒语

**高级动物**及**催妆曲**风格的咒语请以**全角逗号**分隔函数名、参数名与参数。多条咒语（即多个函数调用）以空格分割。

- 动物协鸣

```swift
CardCarousel(咒语: "汪咕呦汪叽嗡呜汪叽 喵呜 呜啾 嘎啾", 施法材料: items, 作用域: CGRect(x: 0, y: 100, width: 393, height: 200))
    .法术目标(view)

// 效果等同于
CardCarousel(frame: CGRect(x: 0, y: 100, width: 393, height: 200), items: items)
    .cardLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(0.7))
    .cardTransformMode(.liner)
    .scrollDirection(.rightToLeft)
    .loopMode(.rollback)
    .add(to: view)
```

- 高级动物

```swift
// 效果同上
CardCarousel(咒语: "矛盾，自私，好色，爱喜，无聊，善良，爱喜 贪婪，真诚 善变，暗淡 无奈，埋怨", 施法材料: items, 作用域: CGRect(x: 0, y: 100, width: 393, height: 200))
    .法术目标(view)
```

- 催妆曲

```swift
// 效果同上
CardCarousel(咒语: "醒呀，画眉在杏枝上歌，画眉人不起是因何，黛棕，远峰尖滴着新黛，正好蘸来描画双蛾，黛棕 晨鸡声呖呖在相催，日神也捧着金镜 画眉在杏枝上歌，她对着如镜的池塘 远峰尖滴着新黛，春莺儿衔了额黄归", 施法材料: items, 作用域: CGRect(x: 0, y: 100, width: 393, height: 200))
    .法术目标(view)
```

- 大威天龙

```swift
let 白素贞 = view
CardCarousel(咒语: "大威天龙", 施法材料: items)
    .法术目标(白素贞)

// 效果等同于
CardCarousel(items: items)
    .minimumLineSpacing(10)
    .pageControl(makePageControl: { UIPageControl() }, position: .centerXBottom)
    .add(to: view)
```

![大威天龙](./Assets/大威天龙.gif)



### 方法列表

```swift
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
```



## 鸣谢

- [TYCyclePagerView](https://github.com/12207480/TYCyclePagerView)
- [scroll_animation](https://github.com/qyz777/scroll_animation)



## 版权协议

`CardCarousel` 基于 MIT 协议进行分发和使用，更多信息参见 [LICENSE](./LICENSE)。


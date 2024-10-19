//
//  CardCarousel.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

public final class CardCarousel: CardCarouselInternalType, CardCarouselInterface {
    public let view: UIView
    
    public init() {
        self.view = CardCarouselView()
    }
    
    /**
     从重用池中获取一个已配置的可重用卡片视图，或者在必要时创建一个新的卡片视图。

     - Parameters:
       - registration: 一个包含卡片类型和配置处理器的注册对象。
       - index: 请求卡片的索引。
       - item: 与卡片关联的数据项。
     - Returns: 配置好的卡片视图。
    */
    public func dequeueConfiguredReusableCard<Card, Item>(
        using registration: CardRegistration<Card, Item>,
        for index: Int,
        item: Item
    ) -> Card where Card: UIView {
        // 尝试将视图转换为 CardCarouselView 类型，如果失败则触发运行时错误
        guard let view = view as? CardCarouselView else { fatalError() }
        
        // 获取重用标识符
        let reuseIdentifier = String(describing: Card.self)
        // 尝试从重用池中获取一个可重用的卡片视图
        if var cards = view.reusableCardCache[reuseIdentifier], let card = cards.popLast() as? Card {
            // 更新重用池
            view.reusableCardCache[reuseIdentifier] = cards
            // 设置卡片的索引
            card._index = index
            // 使用配置处理器对卡片进行配置
            registration.handler(card, view.totalCardsCount == 0 ? index : index % view.totalCardsCount, item)
            // 返回配置好的卡片
            return card
        } else {
            // 如果重用池中没有可用的卡片，创建一个新的卡片视图
            let card = Card()
            // 设置卡片的初始 frame
            card.frame = CGRect(origin: .zero, size: view.actualCardSize)
            // 设置卡片的索引
            card._index = index
            // 使用配置处理器对卡片进行配置
            registration.handler(card, view.totalCardsCount == 0 ? index : index % view.totalCardsCount, item)
            // 返回配置好的卡片
            return card
        }
    }
}

public extension CardCarousel {
    /// CardRegistration 用于注册卡片视图和数据项的配置闭包。
    struct CardRegistration<Card, Item> where Card : UIView {

        public typealias Handler = (_ card: Card, _ index: Int, _ item: Item) -> Void
        
        fileprivate var handler: Handler

        public init(handler: @escaping CardRegistration<Card, Item>.Handler) {
            self.handler = handler
        }
    }
}


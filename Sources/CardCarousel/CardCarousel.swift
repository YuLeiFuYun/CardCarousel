//
//  CardCarousel.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import Combine
import SwiftUI
import UIKit

public class CardCarousel: CardCarouselInterface, CardCarouselInternalType {
    
    var cardCarouselView: CardCarouselBaseView
    
    // MARK: - 初始化方法
    
    public init(frame: CGRect = .zero) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, CardCarouselDataRepresentable>(frame: frame)
    }
    
    public init<Item>(frame: CGRect = .zero, data: [Item]) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(frame: frame, data: data)
    }
    
    public init<Cell: UICollectionViewCell, Item>(
        frame: CGRect = .zero, data: [Item] = [],
        cellRegistration: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(frame: frame, data: data, cellRegistration: cellRegistration)
    }
    
    @available(iOS 13, *)
    public init<Item>(frame: CGRect = .zero, dataPublisher: Published<[Item]>.Publisher) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(frame: frame, dataPublisher: dataPublisher)
    }
    
    @available(iOS 13, *)
    public init<Cell: UICollectionViewCell, Item>(
        frame: CGRect = .zero, dataPublisher: Published<[Item]>.Publisher,
        cellRegistration: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(frame: frame, dataPublisher: dataPublisher, cellRegistration: cellRegistration)
    }
    
    @available(iOS 13, *)
    public init<Content: View, Item>(
        frame: CGRect = .zero, data: [Item] = [],
        @ViewBuilder content: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(frame: frame, data: data, content: content)
    }
    
    @available(iOS 13, *)
    public init<Content: View, Item>(
        frame: CGRect = .zero, dataPublisher: Published<[Item]>.Publisher,
        @ViewBuilder content: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(frame: frame, dataPublisher: dataPublisher, content: content)
    }
    
    public init(咒语: String, 作用域: CGRect = .zero) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, CardCarouselDataRepresentable>(frame: 作用域)
        咒语.施于(cardCarouselView)
    }
    
    public init<Item>(咒语: String, 施法材料: [Item], 作用域: CGRect = .zero) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(frame: 作用域, data: 施法材料)
        咒语.施于(cardCarouselView)
    }
    
    public init<Cell: UICollectionViewCell, Item>(
        咒语: String, 施法材料: [Item], 作用域: CGRect = .zero,
        升华构件: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(frame: 作用域, data: 施法材料, cellRegistration: 升华构件)
        咒语.施于(cardCarouselView)
    }
    
    @available(iOS 13, *)
    public init<Item>(咒语: String, 响应材料: Published<[Item]>.Publisher, 作用域: CGRect = .zero) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(frame: 作用域, dataPublisher: 响应材料)
        咒语.施于(cardCarouselView)
    }
    
    @available(iOS 13, *)
    public init<Cell: UICollectionViewCell, Item>(
        咒语: String, 响应材料: Published<[Item]>.Publisher, 作用域: CGRect = .zero,
        升华构件: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(frame: 作用域, dataPublisher: 响应材料, cellRegistration: 升华构件)
        咒语.施于(cardCarouselView)
    }
    
    @available(iOS 13, *)
    public init<Content: View, Item>(
        咒语: String, 施法材料: [Item], 作用域: CGRect = .zero,
        @ViewBuilder 升华构件: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(frame: 作用域, data: 施法材料, content: 升华构件)
        咒语.施于(cardCarouselView)
    }
    
    @available(iOS 13, *)
    public init<Content: View, Item>(
        咒语: String, 响应材料: Published<[Item]>.Publisher, 作用域: CGRect = .zero,
        @ViewBuilder 升华构件: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(frame: 作用域, dataPublisher: 响应材料, content: 升华构件)
        咒语.施于(cardCarouselView)
    }
    
    // MARK: - 将自身添加到 super view
    
    /// 将自身添加到 super view，未设置 frame 时会铺满 super view
    @discardableResult
    public func move(to superView: UIView) -> CardCarouselBaseView {
        superView.addSubview(cardCarouselView)
        
        if cardCarouselView.frame == .zero {
            cardCarouselView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cardCarouselView.topAnchor.constraint(equalTo: superView.topAnchor),
                cardCarouselView.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
                cardCarouselView.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                cardCarouselView.trailingAnchor.constraint(equalTo: superView.trailingAnchor)
            ])
        }
        
        return cardCarouselView
    }
    
    /// 将自身添加到 super view，同时设置其自动布局约束
    @discardableResult
    public func move(
        to superView: UIView,
        layoutConstraints: (_ cardCarouselView: UIView, _ superView: UIView) -> Void
    ) -> CardCarouselBaseView {
        superView.addSubview(cardCarouselView)
        
        cardCarouselView.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraints(cardCarouselView, superView)
        
        return cardCarouselView
    }
    
    /// 将自身添加到 super view，未设置 frame 时会铺满 super view
    @discardableResult
    public func 法术目标(_ 目标: UIView) -> CardCarouselBaseView {
        move(to: 目标)
    }
    
    /// 将自身添加到 super view，同时设置其自动布局约束
    @discardableResult
    public func 法术目标(_ 目标: UIView, 作用域: (_ cardCarouselView: UIView, _ superView: UIView) -> Void) -> CardCarouselBaseView {
        move(to: 目标, layoutConstraints: 作用域)
    }
}


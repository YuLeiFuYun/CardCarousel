//
//  CardCarouselView.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import SwiftUI

@available(iOS 13, *)
public struct CardCarouselView<Item>: UIViewRepresentable, CardCarouselInterface, CardCarouselInternalType {
    var cardCarouselView: CardCarouselBaseView
    
    @Binding private var items: [Item]
    
    public init(_ items: [Item]) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(items: items)
        self._items = Binding.constant(items)
    }
    
    public init<Cell: UICollectionViewCell>(
        items: [Item] = [], cellRegistration: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(items: items, cellRegistration: cellRegistration)
        self._items = Binding.constant(items)
    }
    
    public init<Content: View>(_ items: [Item], @ViewBuilder content: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content) {
        cardCarouselView = CardCarouselSwiftUIView(items: items, content: content)
        self._items = Binding.constant(items)
    }
    
    public init(_ items: Binding<[Item]>) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(items: items.wrappedValue)
        self._items = items
    }
    
    public init<Content: View>(
        _ items: Binding<[Item]>,
        @ViewBuilder content: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(items: items.wrappedValue, content: content)
        self._items = items
    }
    
    public init<Cell: UICollectionViewCell>(
        _ items: Binding<[Item]>,
        cellRegistration: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(items: items.wrappedValue, cellRegistration: cellRegistration)
        self._items = items
    }
    
    public init(咒语: String, 施法材料: [Item]) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(items: 施法材料)
        咒语.施于(cardCarouselView)
        self._items = Binding.constant(施法材料)
    }
    
    public init<Cell: UICollectionViewCell>(
        咒语: String, 施法材料: [Item],
        升华构件: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(items: 施法材料, cellRegistration: 升华构件)
        咒语.施于(cardCarouselView)
        self._items = Binding.constant(施法材料)
    }
    
    public init(咒语: String, 响应材料: Binding<[Item]>) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(items: 响应材料.wrappedValue)
        咒语.施于(cardCarouselView)
        self._items = 响应材料
    }
    
    public init<Cell: UICollectionViewCell>(
        咒语: String, 响应材料: Binding<[Item]>,
        升华构件: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(items: 响应材料.wrappedValue, cellRegistration: 升华构件)
        咒语.施于(cardCarouselView)
        self._items = 响应材料
    }
    
    public init<Content: View>(
        咒语: String, 施法材料: [Item],
        @ViewBuilder 升华构件: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(items: 施法材料, content: 升华构件)
        咒语.施于(cardCarouselView)
        self._items = Binding.constant(施法材料)
    }
    
    public init<Content: View>(
        咒语: String, 响应材料: Binding<[Item]>,
        @ViewBuilder 升华构件: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(items: 响应材料.wrappedValue, content: 升华构件)
        咒语.施于(cardCarouselView)
        self._items = 响应材料
    }
    
    public func makeUIView(context: Context) -> CardCarouselBaseView {
        cardCarouselView
    }
    
    @MainActor public func updateUIView(_ uiView: CardCarouselBaseView, context: Context) {
        uiView.items = items
    }
}


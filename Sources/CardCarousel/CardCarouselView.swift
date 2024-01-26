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
    
    @Binding private var data: [Item]
    
    public init(_ data: [Item]) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(data: data)
        self._data = Binding.constant(data)
    }
    
    public init<Cell: UICollectionViewCell>(
        data: [Item] = [], cellRegistration: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(data: data, cellRegistration: cellRegistration)
        self._data = Binding.constant(data)
    }
    
    public init<Content: View>(_ data: [Item], @ViewBuilder content: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content) {
        cardCarouselView = CardCarouselSwiftUIView(data: data, content: content)
        self._data = Binding.constant(data)
    }
    
    public init(_ data: Binding<[Item]>) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(data: data.wrappedValue)
        self._data = data
    }
    
    public init<Content: View>(
        _ data: Binding<[Item]>,
        @ViewBuilder content: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(data: data.wrappedValue, content: content)
        self._data = data
    }
    
    public init<Cell: UICollectionViewCell>(
        _ data: Binding<[Item]>,
        cellRegistration: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(data: data.wrappedValue, cellRegistration: cellRegistration)
        self._data = data
    }
    
    public init(咒语: String, 施法材料: [Item]) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(data: 施法材料)
        咒语.施于(cardCarouselView)
        self._data = Binding.constant(施法材料)
    }
    
    public init<Cell: UICollectionViewCell>(
        咒语: String, 施法材料: [Item],
        升华构件: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(data: 施法材料, cellRegistration: 升华构件)
        咒语.施于(cardCarouselView)
        self._data = Binding.constant(施法材料)
    }
    
    public init(咒语: String, 响应材料: Binding<[Item]>) {
        cardCarouselView = CardCarouselUIKitView<ImageCard, Item>(data: 响应材料.wrappedValue)
        咒语.施于(cardCarouselView)
        self._data = 响应材料
    }
    
    public init<Cell: UICollectionViewCell>(
        咒语: String, 响应材料: Binding<[Item]>,
        升华构件: @escaping (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    ) {
        cardCarouselView = CardCarouselUIKitView(data: 响应材料.wrappedValue, cellRegistration: 升华构件)
        咒语.施于(cardCarouselView)
        self._data = 响应材料
    }
    
    public init<Content: View>(
        咒语: String, 施法材料: [Item],
        @ViewBuilder 升华构件: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(data: 施法材料, content: 升华构件)
        咒语.施于(cardCarouselView)
        self._data = Binding.constant(施法材料)
    }
    
    public init<Content: View>(
        咒语: String, 响应材料: Binding<[Item]>,
        @ViewBuilder 升华构件: @escaping (_ index: Int, _ itemIdentifier: Item) -> Content
    ) {
        cardCarouselView = CardCarouselSwiftUIView(data: 响应材料.wrappedValue, content: 升华构件)
        咒语.施于(cardCarouselView)
        self._data = 响应材料
    }
    
    public func makeUIView(context: Context) -> CardCarouselBaseView {
        cardCarouselView
    }
    
    @MainActor public func updateUIView(_ uiView: CardCarouselBaseView, context: Context) {
        uiView.data = data
    }
}


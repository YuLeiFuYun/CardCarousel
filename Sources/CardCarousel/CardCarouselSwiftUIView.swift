//
//  CardCarouselSwiftUIView.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import Combine
import SwiftUI
import UIKit

@available(iOS 13.0, *)
final class CardCarouselSwiftUIView<Content: View, Item>: CardCarouselCore<Item> {
    typealias Handler = (_ index: Int, _ itemIdentifier: Item) -> Content
    
    private var content: Handler
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(frame: CGRect = .zero, items: [Item] = [], @ViewBuilder content: @escaping Handler) {
        self.content = content
        super.init(frame: frame)
        
        self.items = items
        collectionView.register(HostingCell<Content>.self, forCellWithReuseIdentifier: HostingCell<Content>.reuseIdentifier)
    }
    
    init(frame: CGRect = .zero, itemsPublisher: Published<[Item]>.Publisher, @ViewBuilder content: @escaping Handler) {
        self.content = content
        super.init(frame: frame)
        
        collectionView.register(HostingCell<Content>.self, forCellWithReuseIdentifier: HostingCell<Content>.reuseIdentifier)
        itemsPublisher
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 重写
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row % items.count
        let item = items[index]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HostingCell<Content>.reuseIdentifier, for: indexPath) as! HostingCell<Content>
        cell.embed(in: parentViewController()!, withView: content(index, item))
        cell.host?.view.frame = cell.contentView.bounds
        timer?.resume()
        return cell
    }
}

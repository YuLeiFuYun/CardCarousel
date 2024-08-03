//
//  CardCarouselUIKitView.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import Combine
import UIKit

final class CardCarouselUIKitView<Cell: UICollectionViewCell, Item>: CardCarouselCore<Item> {
    typealias Handler = (_ cell: Cell, _ index: Int, _ itemIdentifier: Item) -> Void
    
    private var cellRegistration: Handler?
    
    private var subscriptions = if #available(iOS 13, *) { Set<AnyCancellable>() } else { fatalError() }
    
    init(frame: CGRect = .zero, items: [Item] = [], cellRegistration: Handler? = nil) {
        super.init(frame: frame)
        
        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        self.cellRegistration = cellRegistration
        self.items = items
    }
    
    @available(iOS 13, *)
    init(frame: CGRect = .zero, itemsPublisher: Published<[Item]>.Publisher, cellRegistration: Handler? = nil) {
        super.init(frame: frame)
        
        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        self.cellRegistration = cellRegistration
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
        var cell: UICollectionViewCell
        if let cellRegistration {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
            cellRegistration(cell as! Cell, index, item)
            timer?.resume()
        } else {
            timer?.resume()
            if let imageCard = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCard.reuseIdentifier, for: indexPath) as? ImageCard {
                if let urlString = item as? String, let url = URL(string: urlString) {
                    timer?.suspend()
                    
                    ImageLoadingManager.shared.loadImage(from: url, into: imageCard.imageView, placeholder: placeholder) { [weak self] in
                        self?.timer?.resume()
                    }
                } else if let image = item as? UIImage {
                    imageCard.imageView.image = image
                }
                
                cell = imageCard
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let indexPaths = indexPaths.map { IndexPath(row: $0.row % items.count, section: $0.section) }
        if let onPrefetchItems {
            onPrefetchItems(indexPaths)
        } else if Cell.self is ImageCard.Type, let urlStrings = items as? [String], items.count > 1 {
            var urls: [URL] = []
            for indexPath in indexPaths {
                if let url = URL(string: urlStrings[indexPath.row % items.count]) {
                    urls.append(url)
                }
            }
            ImageLoadingManager.shared.prefetchImages(from: urls)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let indexPaths = indexPaths.map { IndexPath(row: $0.row % items.count, section: $0.section) }
        if let onCancelPrefetchingForItems {
            onCancelPrefetchingForItems(indexPaths)
        } else if Cell.self is ImageCard.Type, let urlStrings = items as? [String], items.count > 1 {
            var urls: [URL] = []
            for indexPath in indexPaths {
                if let url = URL(string: urlStrings[indexPath.row % items.count]) {
                    urls.append(url)
                }
            }
            ImageLoadingManager.shared.cancelLoading(from: urls)
        }
    }
}

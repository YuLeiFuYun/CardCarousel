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
    
    init(frame: CGRect = .zero, data: [Item] = [], cellRegistration: Handler? = nil) {
        super.init(frame: frame)
        
        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        self.cellRegistration = cellRegistration
        self.data = data
    }
    
    @available(iOS 13, *)
    init(frame: CGRect = .zero, dataPublisher: Published<[Item]>.Publisher, cellRegistration: Handler? = nil) {
        super.init(frame: frame)
        
        self.collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        self.cellRegistration = cellRegistration
        dataPublisher
            .sink { [weak self] data in
                self?.data = data
            }
            .store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 重写
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row % data.count
        let item = data[index]
        var cell: UICollectionViewCell
        if let cellRegistration {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
            cellRegistration(cell as! Cell, index, item)
            timer?.resume()
        } else {
            timer?.resume()
            if let imageCard = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCard.reuseIdentifier, for: indexPath) as? ImageCard {
                if let urlString = item as? String, let url = URL(string: urlString) {
                    if let fetchedImage = imageFetcher.fetchedImage(for: url) {
                        imageCard.imageView.image = fetchedImage
                    } else {
                        timer?.suspend()
                        imageCard.imageView.image = placeholder
                        if cardSize != .zero {
                            imageFetcher.fetchImage(for: url, targetSize: cardSize, disableDownsampling: disableDownsampling) { image in
                                DispatchQueue.main.async {
                                    imageCard.imageView.image = image
                                    self.timer?.resume()
                                }
                            }
                        }
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
        let indexPaths = indexPaths.map { IndexPath(row: $0.row % data.count, section: $0.section) }
        if let onPrefetchItems {
            onPrefetchItems(indexPaths)
        } else if Cell.self is ImageCard.Type, let urlStrings = data as? [String], data.count > 1 {
            for indexPath in indexPaths {
                if let url = URL(string: urlStrings[indexPath.row % data.count]) {
                    imageFetcher.fetchImage(for: url, targetSize: cardSize, disableDownsampling: disableDownsampling)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let indexPaths = indexPaths.map { IndexPath(row: $0.row % data.count, section: $0.section) }
        if let onCancelPrefetchingForItems {
            onCancelPrefetchingForItems(indexPaths)
        } else if Cell.self is ImageCard.Type, let urlStrings = data as? [String], data.count > 1 {
            for indexPath in indexPaths {
                if let url = URL(string: urlStrings[indexPath.row % data.count]) {
                    imageFetcher.cancelFetch(url)
                }
            }
        }
    }
}

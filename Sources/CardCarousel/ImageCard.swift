//
//  ImageCard.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

import UIKit

final class ImageCard: UICollectionViewCell {
    var imageView: UIImageView!
    
    let id = UUID()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(origin: .zero, size: frame.size))
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}


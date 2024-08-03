//
//  ImageLoadingManager.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/8/1.
//

import UIKit

public final class ImageLoadingManager {
    public static let shared = ImageLoadingManager()
    
    private var load: ((URL, UIImageView, UIImage?, @escaping () -> Void) -> Void)?
    private var prefetch: (([URL]) -> Void)?
    private var cancel: (([URL]) -> Void)?
    
    private init() { }

    public func configure(
        load: @escaping (_ url: URL, _ imageView: UIImageView, _ placeholder: UIImage?, _ completion: @escaping () -> Void) -> Void,
        prefetch: ((_ urls: [URL]) -> Void)? = nil,
        cancel: ((_ urls: [URL]) -> Void)? = nil
    ) {
        self.load = load
        self.prefetch = prefetch
        self.cancel = cancel
    }
    
    func loadImage(from url: URL, into imageView: UIImageView, placeholder: UIImage?, completion: @escaping () -> Void) {
        load?(url, imageView, placeholder, completion)
    }

    func prefetchImages(from urls: [URL]) {
        prefetch?(urls)
    }

    func cancelLoading(from urls: [URL]) {
        cancel?(urls)
    }
}

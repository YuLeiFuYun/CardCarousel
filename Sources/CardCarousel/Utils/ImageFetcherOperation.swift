//
//  ImageFetcherOperation.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/11.
//

import UIKit

final class ImageFetcherOperation: AsyncOperation {
    // MARK: Properties

    let url: URL
    
    let targetSize: CGSize
    
    let disableDownsampling: Bool
    
    var dataTask: URLSessionDataTask?

    private(set) var fetchedImage: UIImage?

    // MARK: Initialization

    init(url: URL, targetSize: CGSize, disableDownsampling: Bool) {
        self.url = url
        self.targetSize = targetSize
        self.disableDownsampling = disableDownsampling
    }

    // MARK: Operation overrides

    override func main() {
        dataTask = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard error == nil, let self, let data else {
                return
            }
            
            var image: UIImage?
            if self.disableDownsampling {
                image = decode(imageData: data)
            } else {
                image = downsample(imageData: data, to: self.targetSize)
            }
            
            self.fetchedImage = image
            self.finish()
        }
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}

private extension ImageFetcherOperation {
    func downsample(imageData: Data, to pointSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * UIScreen.main.scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard
            let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions),
            let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
        else { return nil }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    func decode(imageData: Data) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }

        let imageOptions = [
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceShouldAllowFloat: true
        ] as CFDictionary

        guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, imageOptions) else {
            return nil
        }

        return UIImage(cgImage: imageRef)
    }
}

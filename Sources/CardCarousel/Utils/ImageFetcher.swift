//
//  ImageFetcher.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/11.
//

import UIKit

final class ImageFetcher {
    // MARK: Properties

    /// A serial `OperationQueue` to lock access to the `fetchQueue` and `completionHandlers` properties.
    private let serialAccessQueue = OperationQueue()

    /// An `OperationQueue` that contains `AsyncFetcherOperation`s for requested data.
    private let fetchQueue = OperationQueue()

    /// A dictionary of arrays of closures to call when an object has been fetched for an id.
    private var completionHandlers = [URL: [(UIImage?) -> Void]]()

    /// An `NSCache` used to store fetched objects.
    private var cache = NSCache<NSURL, UIImage>()
    
    // MARK: Initialization

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }
    
    // MARK: Method
    
    /// Asynchronously fetches data for a specified `URL`
    func fetchImage(for url: URL, targetSize: CGSize, disableDownsampling: Bool, completion: ((UIImage?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion {
                let handlers = self.completionHandlers[url, default: []]
                self.completionHandlers[url] = handlers + [completion]
            }
            
            self._fetchImage(for: url, targetSize: targetSize, disableDownsampling: disableDownsampling)
        }
    }
    
    /// Returns the previously fetched image for a specified `URL`.
    func fetchedImage(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }

    /// Cancels any enqueued asychronous fetches for a specified `URL`. Completion handlers are not called if a fetch is canceled.
    func cancelFetch(_ url: URL) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: url)?.cancel()
            self.completionHandlers[url] = nil
        }
    }
}

private extension ImageFetcher {
    /// Begins fetching data for the provided `URL` invoking the associated completion handler when complete.
    func _fetchImage(for url: URL, targetSize: CGSize, disableDownsampling: Bool) {
        guard operation(for: url) == nil else { return }
        
        if let image = fetchedImage(for: url) {
            invokeCompletionHandlers(for: url, with: image)
        } else {
            let operation = ImageFetcherOperation(url: url, targetSize: targetSize, disableDownsampling: disableDownsampling)
            operation.completionBlock = { [weak operation] in
                guard let fetchedImage = operation?.fetchedImage else { return }
                self.cache.setObject(fetchedImage, forKey: url as NSURL)
                
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: url, with: fetchedImage)
                }
            }
            
            fetchQueue.addOperation(operation)
        }
    }

    /// Returns any enqueued `ImageFetcherOperation` for a specified `URL`.
    func operation(for url: URL) -> ImageFetcherOperation? {
        for case let fetchOperation as ImageFetcherOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.url == url {
            return fetchOperation
        }
        
        return nil
    }

    /// Invokes any completion handlers for a specified `URL`. Once called, the stored array of completion handlers for the `URL` is cleared.
    func invokeCompletionHandlers(for url: URL, with fetchedImage: UIImage) {
        let completionHandlers = self.completionHandlers[url, default: []]
        self.completionHandlers[url] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedImage)
        }
    }
}

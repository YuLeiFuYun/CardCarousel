//
//  AsyncOperation.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/11.
//

import Foundation

// https://www.avanderlee.com/swift/asynchronous-operations/
class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.swipingpageview.asyncoperation", attributes: .concurrent)

    override var isAsynchronous: Bool {
        return true
    }

    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

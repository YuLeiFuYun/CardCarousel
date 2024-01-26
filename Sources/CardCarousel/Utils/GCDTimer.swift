//
//  GCDTimer.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/11.
//

import Foundation

fileprivate enum State {
    case suspended
    case resumed
}

final class GCDTimer {
    private let timer: DispatchSourceTimer
    
    private var state: State = .suspended
    
    private var remainingTimes: Int {
        didSet {
            if remainingTimes == 0 { timer.cancel() }
        }
    }
    
    /// GCD 定时器
    /// - Parameters:
    ///   - startImmediately: 是否立即开始，true 表示立即开始，false 表示 interval 时间后再开始，默认为 true
    ///   - interval: 任务执行间隔，默认为 1 秒
    ///   - leeway: 任务执行精度，DispatchTimeInterval 类型，默认为 .nanoseconds(0)
    ///   - times: 执行次数，0 表示无限重复，默认为 0
    ///   - queue: 任务所在的队列，默认为主队列
    ///   - handler: 所要执行的任务
    init(
        startImmediately: Bool = true,
        interval: DispatchTimeInterval = .seconds(1),
        leeway: DispatchTimeInterval = .nanoseconds(0),
        times: Int = 0,
        queue: DispatchQueue = .main,
        handler: @escaping (GCDTimer) -> Void
    ) {
        guard times >= 0 else {
            fatalError("The number of times cannot be negative!")
        }
        
        self.remainingTimes = times
        self.timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        self.timer.schedule(deadline: .now() + (startImmediately ? .seconds(0) : interval), repeating: interval, leeway: leeway)
        self.timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            handler(self)
            if self.remainingTimes > 0 { self.remainingTimes -= 1 }
        }
    }
    
    func resume() {
        guard state == .suspended else { return }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        guard state == .resumed else { return }
        state = .suspended
        timer.suspend()
    }
    
    deinit {
        timer.setEventHandler { }
        timer.cancel()
        
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
    }
}

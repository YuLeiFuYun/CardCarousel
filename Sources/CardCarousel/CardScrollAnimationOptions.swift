//
//  ScrollAnimationOptions.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/11.
//

import Foundation

public struct CardScrollAnimationOptions {
    var duration: TimeInterval = 0.3
    
    var timingFunction: ScrollTimingFunction
    
    public static let system = CardScrollAnimationOptions(duration: 0, timingFunction: .linear)
    
    public static let linear = CardScrollAnimationOptions(timingFunction: .linear)
    
    public static func linear(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .linear)
    }
    
    public static let quadIn = CardScrollAnimationOptions(timingFunction: .quadIn)
    
    public static func quadIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quadIn)
    }
    
    public static let quadOut = CardScrollAnimationOptions(timingFunction: .quadOut)
    
    public static func quadOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quadOut)
    }
    
    public static let quadInOut = CardScrollAnimationOptions(timingFunction: .quadInOut)
    
    public static func quadInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quadInOut)
    }
    
    public static let cubicIn = CardScrollAnimationOptions(timingFunction: .cubicIn)
    
    public static func cubicIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .cubicIn)
    }
    
    public static let cubicOut = CardScrollAnimationOptions(timingFunction: .cubicOut)
    
    public static func cubicOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .cubicOut)
    }
    
    public static let cubicInOut = CardScrollAnimationOptions(timingFunction: .cubicInOut)
    
    public static func cubicInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .cubicInOut)
    }
    
    public static let quartIn = CardScrollAnimationOptions(timingFunction: .quartIn)
    
    public static func quartIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quartIn)
    }
    
    public static let quartOut = CardScrollAnimationOptions(timingFunction: .quartOut)
    
    public static func quartOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quartOut)
    }
    
    public static let quartInOut = CardScrollAnimationOptions(timingFunction: .quartInOut)
    
    public static func quartInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quartInOut)
    }
    
    public static let quintIn = CardScrollAnimationOptions(timingFunction: .quintIn)
    
    public static func quintIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quintIn)
    }
    
    public static let quintOut = CardScrollAnimationOptions(timingFunction: .quintOut)
    
    public static func quintOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quintOut)
    }
    
    public static let quintInOut = CardScrollAnimationOptions(timingFunction: .quintInOut)
    
    public static func quintInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .quintInOut)
    }
    
    public static let sineIn = CardScrollAnimationOptions(timingFunction: .sineIn)
    
    public static func sineIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .sineIn)
    }
    
    public static let sineOut = CardScrollAnimationOptions(timingFunction: .sineOut)
    
    public static func sineOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .sineOut)
    }
    
    public static let sineInOut = CardScrollAnimationOptions(timingFunction: .sineInOut)
    
    public static func sineInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .sineInOut)
    }
    
    public static let expoIn = CardScrollAnimationOptions(timingFunction: .expoIn)
    
    public static func expoIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .expoIn)
    }
    
    public static let expoOut = CardScrollAnimationOptions(timingFunction: .expoOut)
    
    public static func expoOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .expoOut)
    }
    
    public static let expoInOut = CardScrollAnimationOptions(timingFunction: .expoInOut)
    
    public static func expoInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .expoInOut)
    }
    
    public static let circleIn = CardScrollAnimationOptions(timingFunction: .circleIn)
    
    public static func circleIn(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .circleIn)
    }
    
    public static let circleOut = CardScrollAnimationOptions(timingFunction: .circleOut)
    
    public static func circleOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .circleOut)
    }
    
    public static let circleInOut = CardScrollAnimationOptions(timingFunction: .circleInOut)
    
    public static func circleInOut(duration: TimeInterval) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .circleInOut)
    }
    
    public static func custom(duration: TimeInterval, function: @escaping (CGFloat, CGFloat, CGFloat, CGFloat) -> CGFloat) -> CardScrollAnimationOptions {
        CardScrollAnimationOptions(duration: duration, timingFunction: .custom(function))
    }
}

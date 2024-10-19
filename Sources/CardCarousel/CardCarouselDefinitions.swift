//
//  CardCarousel+.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/18.
//

extension CardCarousel {
    /// 表示尺寸的结构体，支持基于百分比和绝对值的尺寸表示。
    public struct Dimension {
        /// 尺寸选项枚举，支持基于父视图宽度或高度的百分比尺寸（可选地包含填充）和绝对尺寸。
        enum Option {
            case fractionalWidth(CGFloat, padding: CGFloat)
            case fractionalHeight(CGFloat, padding: CGFloat)
            case absolute(CGFloat) // 绝对尺寸。
        }
        
        var option: Option // 当前尺寸的选项。
        
        init(option: Option) {
            self.option = option
        }
        
        /// 创建一个基于父视图宽度的百分比尺寸，可选地包含 padding。
        ///
        /// - Parameters:
        ///   - fractionalWidth: 父视图宽度的百分比。
        ///   - padding: 表示在计算基于父视图宽度的百分比尺寸时，从父视图的左右两侧各留出的空间。
        /// - Returns: 一个新的尺寸实例。
        public static func fractionalWidth(_ fractionalWidth: CGFloat, padding: CGFloat = 0) -> Dimension {
            Dimension(option: .fractionalWidth(fractionalWidth, padding: padding))
        }

        /// 创建一个基于父视图高度的百分比尺寸，可选地包含 padding。
        ///
        /// - Parameters:
        ///   - fractionalHeight: 父视图高度的百分比。
        ///   - padding:表示在计算基于父视图高度的百分比尺寸时，从父视图的上下两侧各留出的空间。
        /// - Returns: 一个新的尺寸实例。
        public static func fractionalHeight(_ fractionalHeight: CGFloat, padding: CGFloat = 0) -> Dimension {
            Dimension(option: .fractionalHeight(fractionalHeight, padding: padding))
        }

        /// 创建一个绝对尺寸
        ///
        /// - Parameter absoluteDimension: 绝对尺寸值。
        /// - Returns: 一个新的尺寸实例。
        public static func absolute(_ absoluteDimension: CGFloat) -> Dimension {
            Dimension(option: .absolute(absoluteDimension))
        }
        
        /// 根据容器的尺寸解析出实际值
        func resolvedValue(within containerSize: CGSize) -> CGFloat {
            var resolvedValue: CGFloat = 0
            switch option {
            case let .fractionalWidth(ratio, padding):
                resolvedValue = (containerSize.width - 2 * padding) * ratio
            case let .fractionalHeight(ratio, padding):
                resolvedValue = (containerSize.height - 2 * padding) * ratio
            case let .absolute(value):
                resolvedValue = value
            }
            
            return resolvedValue
        }
    }

    /// 表示卡片尺寸的结构体，使用 `Dimension` 来定义宽度和高度。
    public struct CardSize {
        public var width: Dimension
        public var height: Dimension
    }
    
    /// 滚动停止时卡片的对齐方式
    public struct CardAlignment {
        enum Option {
            /// 中心对齐，卡片的中心与轮播组件的中心对齐。
            /// - Parameter offset: 用于设置卡片在滚动方向上的偏移量。
            case center(offset: CGFloat)
            
            /// Leading 对齐，卡片的 Leading 边与轮播组件的 Leading 边对齐。
            /// - Parameter offset: 用于设置卡片在滚动方向上的偏移量。
            case leading(offset: CGFloat)
        }

        var option: Option
        
        init(option: Option) {
            self.option = option
        }
        
        public static let center = CardAlignment(option: .center(offset: 0))
        
        public static func center(offset: CGFloat) -> CardAlignment {
            .init(option: .center(offset: offset))
        }
        
        public static let leading = CardAlignment(option: .leading(offset: 0))
        
        public static func leading(offset: CGFloat) -> CardAlignment {
            .init(option: .leading(offset: offset))
        }
    }
    
    public enum PagingThreshold {
        case fractional(CGFloat)
        case absolute(CGFloat)
        
        func resolvedPagingThreshold(cardDimensionWithSpacing: CGFloat) -> CGFloat {
            switch self {
            case .fractional(let value):
                // 验证 fractional 范围
                if value < 0 || value >= 1 {
                    fatalError("Invalid fractional value: \(value). It must be in the range [0, 1).")
                }
                return value

            case .absolute(let value):
                // 验证 absolute 范围
                if value < 0 || value >= cardDimensionWithSpacing {
                    fatalError("Invalid absolute value: \(value). It must be in the range [0, \(cardDimensionWithSpacing)).")
                }
                return value / cardDimensionWithSpacing
            }
        }
    }

    public enum ScrollDirection: Int {
        case leftToRight = 1
        case rightToLeft = 2
        case topToBottom = 3
        case bottomToTop = 4
        
        var isHorizontal: Bool {
            return self == .leftToRight || self == .rightToLeft
        }
    }
    
    public enum CardTransformStyle {
        case none
        case zoom(maxCardScale: CGFloat, inactiveCardAlpha: CGFloat)
    }
    
    public enum ScrollMode {
        case automatic(timeInterval: TimeInterval)
        case manual
    }
    
    public enum LoopMode {
        case circular   // 环形循环
        case single     // 滚动到最后就停止
    }
    
    enum SlideDirection {
        case forward
        case backward
    }
}

//
//  SpellParser.swift
//  CardCarousel
//
//  Created by 玉垒浮云 on 2024/1/21.
//

import UIKit

fileprivate enum SpellStyle: CaseIterable {
    case 动物协鸣
    case 高级动物
    case 催妆曲
    
    var digitWords: [String] {
        switch self {
        case .动物协鸣: ["汪", "啾", "喵", "咩", "哞", "呱", "嘎", "叽", "吱", "嘶"]
        case .高级动物: ["爱", "贪", "嗔", "痴", "恨", "苦", "忧", "喜", "怨", "怒"]
        case .催妆曲: ["黛", "墨", "碧", "朱", "紫", "黄", "蓝", "棕", "灰", "白"]
        }
    }
}

fileprivate var spellStyle: SpellStyle = .动物协鸣

fileprivate let execUnitSeparator: Character = " "

fileprivate let wordSeparator: Character = "，"

extension String {
    func 施于(_ 法术目标: CardCarouselBaseView) {
        guard let first else {
            fatalError("咒语不能为空！")
        }
        
        if self == "大威天龙" {
            法术目标.minimumLineSpacing = 10
            法术目标.makePageControl = { UIPageControl() }
            法术目标.pageControlPosition = .centerXBottom
            return
        }
        
        spellStyle = .动物协鸣
        let 动物协鸣函数单词数组 = Func.allCases.map(\.value)
        
        spellStyle = .高级动物
        let 高级动物函数单词数组 = Func.allCases.map(\.value)
        
        spellStyle = .催妆曲
        let 催妆曲函数单词数组 = Func.allCases.map(\.value)
        
        // 将咒语分割成执行单元
        let execUnits = split(separator: execUnitSeparator).map { String($0) }
        
        // 判断咒语风格
        if 动物协鸣函数单词数组.contains(String(first)) {
            spellStyle = .动物协鸣
        } else {
            let firstExecUnit = execUnits[0]
            var idx = firstExecUnit.startIndex
            while idx < firstExecUnit.endIndex, firstExecUnit[idx] != wordSeparator {
                idx = index(after: idx)
            }
            
            let firstWord = String(firstExecUnit[firstExecUnit.startIndex..<idx])
            if 高级动物函数单词数组.contains(firstWord) {
                spellStyle = .高级动物
            } else if 催妆曲函数单词数组.contains(firstWord) {
                spellStyle = .催妆曲
            } else {
                fatalError("\(firstWord): 无效的咒语！")
            }
        }
        
        // 解析咒语
        for execUnit in execUnits {
            execUnit.parser(spellTarget: 法术目标)
        }
    }
}

fileprivate extension String {
    func parser(spellTarget: CardCarouselBaseView) {
        guard !isEmpty else {
            fatalError("无效的咒语！")
        }
        
        // 获取函数名
        var currentIndex = startIndex
        if spellStyle == .动物协鸣 {
            currentIndex = index(after: startIndex)
        } else {
            while currentIndex < endIndex, self[currentIndex] != wordSeparator {
                currentIndex = index(after: currentIndex)
            }
        }
        
        let funcName = String(self[startIndex..<currentIndex])
        
        // 根据函数名执行不同操作
        if funcName == .cardLayoutSize {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let pathName = getPathName(currentIndex: &currentIndex)
            if pathName == .lsWidthDimension {
                spellTarget.cardLayoutSize = getCardLayoutSize(currentIndex: &currentIndex, path: .lsWidthDimension)
            } else if pathName == .lsHeightDimension {
                spellTarget.cardLayoutSize = getCardLayoutSize(currentIndex: &currentIndex, path: .lsHeightDimension)
            } else {
                fatalError("cardLayoutSize(\(String.cardLayoutSize)): 无效的参数")
            }
        } else if funcName == .minimumLineSpacing {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let value = parsingDigits(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("minimumLineSpacing(\(String.minimumLineSpacing)): 多余的参数")
            }
            
            spellTarget.minimumLineSpacing = value
        } else if funcName == .cardTransformMode {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let pathName = getPathName(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("cardTransformMode(\(String.cardTransformMode)): 多余的参数")
            }
            
            if pathName == .tmLiner {
                spellTarget.cardTransformMode = .liner
            } else if pathName == .tmCoverflow {
                spellTarget.cardTransformMode = .coverflow
            } else {
                fatalError("cardTransformMode(\(String.cardTransformMode)): 无效的参数")
            }
        } else if funcName == .disableCurrentCardAlwaysOnTop {
            guard currentIndex >= endIndex else {
                fatalError("disableCurrentCardAlwaysOnTop(\(String.disableCurrentCardAlwaysOnTop)): 多余的参数")
            }
            
            spellTarget.disableCurrentCardAlwaysOnTop = true
        } else if funcName == .sideMargin {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let value = parsingDigits(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("sideMargin(\(String.sideMargin)): 多余的参数")
            }
            
            spellTarget.sideMargin = value
        } else if funcName == .scrollStopAlignment || funcName == .singleCardAlignment {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            if funcName == .scrollStopAlignment {
                spellTarget.cardScrollStopAlignment = getScrollStopAlignment(currentIndex: &currentIndex)
            } else {
                spellTarget.singleCardAlignment = getScrollStopAlignment(currentIndex: &currentIndex)
            }
        } else if funcName == .scrollDirection {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let pathName = getPathName(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("scrollDirection(\(String.scrollDirection)): 多余的参数")
            }
            
            if pathName == .sdLeftToRight {
                spellTarget.scrollDirection = .leftToRight
            } else if pathName == .sdRightToLeft {
                spellTarget.scrollDirection = .rightToLeft
            } else if pathName == .sdTopToBottom {
                spellTarget.scrollDirection = .topToBottom
            } else if pathName == .sdBottomToTop {
                spellTarget.scrollDirection = .bottomToTop
            } else {
                fatalError("scrollDirection(\(String.scrollDirection)): 无效的参数")
            }
        } else if funcName == .scrollMode {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let pathName = getPathName(currentIndex: &currentIndex)
            if pathName == .smManual {
                guard currentIndex >= endIndex else {
                    fatalError("scrollMode(\(String.scrollMode)): 多余的参数")
                }
                
                spellTarget.scrollMode = .manual
            } else if pathName == .smAutomatic {
                let value = parsingDigits(currentIndex: &currentIndex)
                guard currentIndex >= endIndex else {
                    fatalError("scrollMode(\(String.scrollMode)): 多余的参数")
                }
                
                spellTarget.scrollMode = .automatic(timeInterval: Double(value))
            } else {
                fatalError("scrollMode(\(String.scrollMode)): 无效的参数")
            }
        } else if funcName == .loopMode {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let pathName = getPathName(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("loopMode(\(String.loopMode)): 多余的参数")
            }
            
            if pathName == .lmCircular {
                spellTarget.loopMode = .circular
            } else if pathName == .lmRollback {
                spellTarget.loopMode = .rollback
            } else if pathName == .lmSingle {
                spellTarget.loopMode = .single
            } else {
                fatalError("loopMode(\(String.loopMode)): 无效的参数")
            }
        } else if funcName == .pagingThreshold {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let pathName = getPathName(currentIndex: &currentIndex)
            let value = parsingDigits(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("pagingThreshold(\(String.pagingThreshold)): 多余的参数")
            }
            
            if pathName == .ptFractional {
                spellTarget.cardPagingThreshold = .fractional(value)
            } else if pathName == .ptAbsolute {
                spellTarget.cardPagingThreshold = .absolute(value)
            } else {
                fatalError("pagingThreshold(\(String.pagingThreshold)): 无效的参数")
            }
        } else if funcName == .decelerationRate {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let value = parsingDigits(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("decelerationRate(\(String.decelerationRate)): 多余的参数")
            }
            
            spellTarget.decelerationRate = value
        } else if funcName == .disableUserSwipe {
            guard currentIndex >= endIndex else {
                fatalError("disableUserSwipe(\(String.disableUserSwipe)): 多余的参数")
            }
            
            spellTarget.disableUserSwipe = true
        } else if funcName == .cardCornerRadius {
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: currentIndex)
            }
            
            let value = parsingDigits(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("cardCornerRadius(\(String.cardCornerRadius)): 多余的参数")
            }
            
            spellTarget.cardCornerRadius = value
        } else {
            fatalError("无效的函数名: \(funcName)")
        }
    }
}

fileprivate extension String {
    func parsingDigits(currentIndex: inout Index) -> CGFloat {
        func handler(currentIndex: inout Index) -> Int? {
            var digit: Int?
            for (idx, digitWord) in spellStyle.digitWords.enumerated() {
                if digitWord == String(self[currentIndex]) {
                    digit = idx
                    break
                }
            }
            
            if digit != nil {
                currentIndex = index(after: currentIndex)
            }
            
            return digit
        }
        
        var digitStringArray: [String] = []
        while currentIndex < endIndex, let digit = handler(currentIndex: &currentIndex) {
            digitStringArray.append("\(digit)")
        }
        
        guard !digitStringArray.isEmpty else {
            fatalError("缺少必要参数")
        }
        
        if spellStyle != .动物协鸣, currentIndex < endIndex {
            guard self[currentIndex] == wordSeparator else {
                fatalError("无效的参数")
            }
            
            // 丢弃 word separator
            currentIndex = index(after: currentIndex)
        }
        
        if digitStringArray[0] == "0" {
            digitStringArray[0] = "0."
        }
        
        let numberString = digitStringArray.reduce("", +)
        return CGFloat(Double(numberString) ?? 0)
    }
    
    func getPathName(currentIndex: inout Index) -> String {
        guard currentIndex < endIndex else {
            fatalError("缺少必要参数")
        }
        
        var nextIndex = index(after: currentIndex)
        if spellStyle != .动物协鸣 {
            // 获取下一个 word separator 的索引
            while nextIndex < endIndex, self[nextIndex] != wordSeparator {
                nextIndex = index(after: nextIndex)
            }
        }
        
        defer {
            currentIndex = nextIndex
            if spellStyle != .动物协鸣, currentIndex < endIndex {
                // 丢弃 word separator
                currentIndex = index(after: nextIndex)
            }
        }
        
        return String(self[currentIndex..<nextIndex])
    }
    
    func getScrollStopAlignment(currentIndex: inout Index) -> CardScrollStopAlignment {
        var result: CardScrollStopAlignment = .center
        let pathName = getPathName(currentIndex: &currentIndex)
        if currentIndex < endIndex {
            let value = parsingDigits(currentIndex: &currentIndex)
            guard currentIndex >= endIndex else {
                fatalError("scrollStopAlignment(\(String.scrollStopAlignment)): 多余的参数")
            }
            
            if pathName == .ssaCenter {
                result = .center(offset: value)
            } else if pathName == .ssaHead {
                result = .head(offset: value)
            } else {
                fatalError("scrollStopAlignment(\(String.scrollStopAlignment)): 无效的参数")
            }
        } else {
            if pathName == .ssaCenter {
                result = .center
            } else if pathName == .ssaHead {
                result = .head
            } else {
                fatalError("scrollStopAlignment(\(String.scrollStopAlignment)): 无效的参数")
            }
        }
        
        return result
    }
    
    func getCardLayoutSize(currentIndex: inout Index, path: String) -> CardLayoutSize {
        func handler(currentIndex: inout Index, path: String, subPath: String) -> CardLayoutSize {
            var result = CardLayoutSize()
            let value1 = parsingDigits(currentIndex: &currentIndex)
            if currentIndex < endIndex {
                var pathName = getPathName(currentIndex: &currentIndex)
                if pathName == .lsInset {
                    guard subPath != .lsAbsolute else {
                        fatalError("cardLayoutSize(\(String.cardLayoutSize)): 无效的参数")
                    }
                    
                    let value2 = parsingDigits(currentIndex: &currentIndex)
                    if currentIndex < endIndex {
                        pathName = getPathName(currentIndex: &currentIndex)
                        if pathName == .lsHeightDimension, path == .lsWidthDimension {
                            result.widthDimension = .fractionalWidth(value1, inset: value2)
                            
                            let layoutSize = getCardLayoutSize(currentIndex: &currentIndex, path: .lsHeightDimension)
                            result.heightDimension = layoutSize.heightDimension
                        } else {
                            fatalError("cardLayoutSize(\(String.cardLayoutSize)): 无效的参数")
                        }
                    } else {
                        if path == .lsWidthDimension {
                            if subPath == .lsFractionalWidth {
                                result.widthDimension = .fractionalWidth(value1, inset: value2)
                            } else {
                                result.widthDimension = .fractionalHeight(value1, inset: value2)
                            }
                        } else {
                            if subPath == .lsFractionalWidth {
                                result.heightDimension = .fractionalWidth(value1, inset: value2)
                            } else {
                                result.heightDimension = .fractionalHeight(value1, inset: value2)
                            }
                        }
                    }
                } else if pathName == .lsHeightDimension, path == .lsWidthDimension {
                    result.widthDimension = .fractionalWidth(value1)
                    
                    let layoutSize = getCardLayoutSize(currentIndex: &currentIndex, path: .lsHeightDimension)
                    result.heightDimension = layoutSize.heightDimension
                } else {
                    fatalError("cardLayoutSize(\(String.cardLayoutSize)): 无效的参数")
                }
            } else {
                if path == .lsWidthDimension {
                    if subPath == .lsFractionalWidth {
                        result.widthDimension = .fractionalWidth(value1)
                    } else if subPath == .lsFractionalHeight {
                        result.widthDimension = .fractionalHeight(value1)
                    } else {
                        result.widthDimension = .absolute(value1)
                    }
                } else {
                    if subPath == .lsFractionalWidth {
                        result.heightDimension = .fractionalWidth(value1)
                    } else if subPath == .lsFractionalHeight {
                        result.heightDimension = .fractionalHeight(value1)
                    } else {
                        result.heightDimension = .absolute(value1)
                    }
                }
            }
            
            return result
        }
        
        var result = CardLayoutSize()
        let pathName = getPathName(currentIndex: &currentIndex)
        if pathName == .lsFractionalWidth {
            result = handler(currentIndex: &currentIndex, path: path, subPath: .lsFractionalWidth)
        } else if pathName == .lsFractionalHeight {
            result = handler(currentIndex: &currentIndex, path: path, subPath: .lsFractionalHeight)
        } else if pathName == .lsAbsolute {
            result = handler(currentIndex: &currentIndex, path: path, subPath: .lsAbsolute)
        } else {
            fatalError("cardLayoutSize(\(String.cardLayoutSize)): 参数名错误")
        }
        
        return result
    }
}

fileprivate enum Func: CaseIterable {
    case cardLayoutSize
    case minimumLineSpacing
    case cardTransformMode
    case disableCurrentCardAlwaysOnTop
    case sideMargin
    case scrollStopAlignment
    case singleCardAlignment
    case scrollDirection
    case scrollMode
    case loopMode
    case pagingThreshold
    case decelerationRate
    case disableUserSwipe
    case cardCornerRadius
    
    var value: String {
        switch self {
        case .cardLayoutSize: .cardLayoutSize
        case .minimumLineSpacing: .minimumLineSpacing
        case .cardTransformMode: .cardTransformMode
        case .disableCurrentCardAlwaysOnTop: .disableCurrentCardAlwaysOnTop
        case .sideMargin: .sideMargin
        case .scrollStopAlignment: .scrollStopAlignment
        case .singleCardAlignment: .singleCardAlignment
        case .scrollDirection: .scrollDirection
        case .scrollMode: .scrollMode
        case .loopMode: .loopMode
        case .pagingThreshold: .pagingThreshold
        case .decelerationRate: .decelerationRate
        case .disableUserSwipe: .disableUserSwipe
        case .cardCornerRadius: .cardCornerRadius
        }
    }
}

fileprivate extension String {
    static var cardLayoutSize: String {
        switch spellStyle {
        case .动物协鸣: "汪"
        case .高级动物: "矛盾"
        case .催妆曲: "醒呀"
        }
    }
    
    static var lsWidthDimension: String {
        switch spellStyle {
        case .动物协鸣: "咕"
        case .高级动物: "自私"
        case .催妆曲: "画眉在杏枝上歌"
        }
    }
    
    static var lsHeightDimension: String {
        switch spellStyle {
        case .动物协鸣: "嗡"
        case .高级动物: "无聊"
        case .催妆曲: "远峰尖滴着新黛"
        }
    }
    
    static var lsFractionalWidth: String {
        switch spellStyle {
        case .动物协鸣: "呦"
        case .高级动物: "好色"
        case .催妆曲: "画眉人不起是因何"
        }
    }
    
    static var lsFractionalHeight: String {
        switch spellStyle {
        case .动物协鸣: "呜"
        case .高级动物: "善良"
        case .催妆曲: "正好蘸来描画双蛾"
        }
    }
    
    static var lsAbsolute: String {
        switch spellStyle {
        case .动物协鸣: "嗷"
        case .高级动物: "博爱"
        case .催妆曲: "春莺儿衔了额黄归"
        }
    }
    
    static var lsInset: String {
        switch spellStyle {
        case .动物协鸣: "嘤"
        case .高级动物: "诡辩"
        case .催妆曲: "起呀"
        }
    }
    
    static var minimumLineSpacing: String {
        switch spellStyle {
        case .动物协鸣: "啾"
        case .高级动物: "虚伪"
        case .催妆曲: "从睡乡醒回"
        }
    }
    
    static var cardTransformMode: String {
        switch spellStyle {
        case .动物协鸣: "喵"
        case .高级动物: "贪婪"
        case .催妆曲: "晨鸡声呖呖在相催"
        }
    }
    
    static var tmLiner: String {
        switch spellStyle {
        case .动物协鸣: "呜"
        case .高级动物: "真诚"
        case .催妆曲: "日神也捧着金镜"
        }
    }
    
    static var tmCoverflow: String {
        switch spellStyle {
        case .动物协鸣: "嗷"
        case .高级动物: "金钱"
        case .催妆曲: "等候你起来梳早妆"
        }
    }
    
    static var disableCurrentCardAlwaysOnTop: String {
        switch spellStyle {
        case .动物协鸣: "咩"
        case .高级动物: "欺骗"
        case .催妆曲: "看呀"
        }
    }
    
    static var sideMargin: String {
        switch spellStyle {
        case .动物协鸣: "哞"
        case .高级动物: "幻想"
        case .催妆曲: "霞织的五彩衣裳"
        }
    }
    
    static var scrollStopAlignment: String {
        switch spellStyle {
        case .动物协鸣: "呱"
        case .高级动物: "疑惑"
        case .催妆曲: "趁草际珠垂"
        }
    }
    
    static var ssaCenter: String {
        switch spellStyle {
        case .动物协鸣: "咕"
        case .高级动物: "地狱"
        case .催妆曲: "画眉在杏枝上歌"
        }
    }
    
    static var ssaHead: String {
        switch spellStyle {
        case .动物协鸣: "嗡"
        case .高级动物: "天堂"
        case .催妆曲: "画眉人不起是因何"
        }
    }
    
    static var singleCardAlignment: String {
        switch spellStyle {
        case .动物协鸣: "呦"
        case .高级动物: "简单"
        case .催妆曲: "春莺儿衔了额黄归"
        }
    }
    
    static var scaCenter: String {
        ssaCenter
    }
    
    static var scaHead: String {
        ssaHead
    }
    
    static var scrollDirection: String {
        switch spellStyle {
        case .动物协鸣: "呜"
        case .高级动物: "善变"
        case .催妆曲: "画眉在杏枝上歌"
        }
    }
    
    static var sdLeftToRight: String {
        switch spellStyle {
        case .动物协鸣: "汪"
        case .高级动物: "辉煌"
        case .催妆曲: "杨柳的丝发飘扬"
        }
    }
    
    static var sdRightToLeft: String {
        switch spellStyle {
        case .动物协鸣: "啾"
        case .高级动物: "暗淡"
        case .催妆曲: "她对着如镜的池塘"
        }
    }
    
    static var sdTopToBottom: String {
        switch spellStyle {
        case .动物协鸣: "喵"
        case .高级动物: "得意"
        case .催妆曲: "百花是薰沐已毕"
        }
    }
    
    static var sdBottomToTop: String {
        switch spellStyle {
        case .动物协鸣: "咩"
        case .高级动物: "伤感"
        case .催妆曲: "她们身上喷出芬芳"
        }
    }
    
    static var scrollMode: String {
        switch spellStyle {
        case .动物协鸣: "嗡"
        case .高级动物: "好强"
        case .催妆曲: "画眉人不起是因何"
        }
    }
    
    static var smAutomatic: String {
        switch spellStyle {
        case .动物协鸣: "咕"
        case .高级动物: "怀恨"
        case .催妆曲: "远峰尖滴着新黛"
        }
    }
    
    static var smManual: String {
        switch spellStyle {
        case .动物协鸣: "嗡"
        case .高级动物: "报复"
        case .催妆曲: "正好蘸来描画双蛾"
        }
    }
    
    static var loopMode: String {
        switch spellStyle {
        case .动物协鸣: "嘎"
        case .高级动物: "无奈"
        case .催妆曲: "远峰尖滴着新黛"
        }
    }
    
    static var lmCircular: String {
        switch spellStyle {
        case .动物协鸣: "汪"
        case .高级动物: "争夺"
        case .催妆曲: "趁草际珠垂"
        }
    }
    
    static var lmRollback: String {
        switch spellStyle {
        case .动物协鸣: "啾"
        case .高级动物: "埋怨"
        case .催妆曲: "春莺儿衔了额黄归"
        }
    }
    
    static var lmSingle: String {
        switch spellStyle {
        case .动物协鸣: "喵"
        case .高级动物: "冒险"
        case .催妆曲: "赶快拿妆梳理好"
        }
    }
    
    static var pagingThreshold: String {
        switch spellStyle {
        case .动物协鸣: "叽"
        case .高级动物: "孤独"
        case .催妆曲: "正好蘸来描画双蛾"
        }
    }
    
    static var ptFractional: String {
        switch spellStyle {
        case .动物协鸣: "咕"
        case .高级动物: "伟大"
        case .催妆曲: "画眉在杏枝上歌"
        }
    }
    
    static var ptAbsolute: String {
        switch spellStyle {
        case .动物协鸣: "嗡"
        case .高级动物: "渺小"
        case .催妆曲: "画眉人不起是因何"
        }
    }
    
    static var decelerationRate: String {
        switch spellStyle {
        case .动物协鸣: "吱"
        case .高级动物: "脆弱"
        case .催妆曲: "杨柳的丝发飘扬"
        }
    }
    
    static var disableUserSwipe: String {
        switch spellStyle {
        case .动物协鸣: "嘶"
        case .高级动物: "忍让"
        case .催妆曲: "她对着如镜的池塘"
        }
    }
    
    static var cardCornerRadius: String {
        switch spellStyle {
        case .动物协鸣: "嗷"
        case .高级动物: "复杂"
        case .催妆曲: "她们身上喷出芬芳"
        }
    }
}

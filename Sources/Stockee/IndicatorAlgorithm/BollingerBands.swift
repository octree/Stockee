//
//  BollingerBands.swift
//  Stockee
//
//  Created by octree on 2022/3/14.
//
//  Copyright (c) 2022 Octree <fouljz@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import CoreGraphics
import Foundation

/// BOLL 指标
public struct BOLLIndicator: Equatable {
    public var lower: CGFloat
    public var middle: CGFloat
    public var upper: CGFloat

    public init(lower: CGFloat, middle: CGFloat, upper: CGFloat) {
        self.lower = lower
        self.middle = middle
        self.upper = upper
    }
}

/// 用于计算 BOLL 指标的算法
public struct BollingerBandsAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [BOLLIndicator]
    /// BOLL 计算周期
    public let period: Int
    /// 标准差的倍数
    public let standardDeviationMultiplier: CGFloat

    /// 创建一个计算 BOLL 指标的算法
    /// - Parameters:
    ///   - period: 计算周期，默认为 20
    ///   - standardDeviation: 标准差的倍数，默认为 2 倍
    public init(period: Int = 20, standardDeviationMultiplier: CGFloat = 2) {
        self.period = period
        self.standardDeviationMultiplier = standardDeviationMultiplier
    }

    /// 处理蜡烛图数据，生成 BOLL 指标数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: BOLL 数据
    public func process(_ data: [Input]) -> [BOLLIndicator] {
        guard data.count >= period else { return [] }
        let maList = MovingAverageAlgorithm(period: period).process(data)
        var result: [BOLLIndicator] = []

        func standardDeviation(at index: Int, ma: CGFloat) -> CGFloat {
            var deviation: CGFloat = 0
            for idx in (index + 1 - period)...index {
                deviation += pow(data[idx].close - ma, 2)
            }
            deviation /= CGFloat(period)
            return pow(deviation, 0.5)
        }

        for index in (period - 1) ..< data.count {
            let ma = maList[index - period + 1]
            let std = standardDeviation(at: index, ma: ma)
            let upper = ma + std * standardDeviationMultiplier
            let lower = ma - std * standardDeviationMultiplier
            result.append(.init(lower: lower, middle: ma, upper: upper))
        }
        return result
    }
}

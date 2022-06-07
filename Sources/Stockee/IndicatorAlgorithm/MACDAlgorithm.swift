//
//  MACDAlgorithm.swift
//  Stockee
//
//  Created by octree on 2022/3/15.
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

/// MACD 指标
public struct MACDIndicator: Equatable {
    /// 12 日 EMA 与 26 日 EMA 的差
    public var diff: CGFloat
    /// DIFF 的 EMA(9)
    public var dea: CGFloat?
    /// 2 * (DIFF - DEA)
    public var histogram: CGFloat?

    public init(diff: CGFloat, dea: CGFloat? = nil, histogram: CGFloat? = nil) {
        self.diff = diff
        self.dea = dea
        self.histogram = histogram
    }
}

/// 计算 MACD 指标的算法，以 MACD(12, 26, 9) 为例，
/// 短线使用 EMA(12)，长线使用 EMA(26)，DEA 计算使用 EMA(9)
/// 数据数量为 max(0, data.count - 26 + 1)
///
/// ```
/// MACD Line: (12-day EMA - 26-day EMA)
/// Signal Line: 9-day EMA of MACD Line
/// MACD Histogram: MACD Line - Signal Line
/// ```
public struct MACDAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public let shorterPeroid: Int
    public let longerPeroid: Int
    public let deaPeroid: Int

    public typealias Output = [MACDIndicator]

    public init(shorterPeroid: Int = 12, longerPeroid: Int = 26, deaPeroid: Int = 9) {
        assert(shorterPeroid < longerPeroid)
        self.shorterPeroid = shorterPeroid
        self.longerPeroid = longerPeroid
        self.deaPeroid = deaPeroid
    }

    public func process(_ data: [Input]) -> [MACDIndicator] {
        guard data.count >= longerPeroid else { return [] }
        // EMA(close, 12)
        let ema12 = ExponentialMovingAverageAlgorithm(period: shorterPeroid)
            .process(data)
            .dropFirst(longerPeroid - shorterPeroid)
        // EMA(close, 26)
        let ema26 = ExponentialMovingAverageAlgorithm(period: longerPeroid).process(data)
        assert(ema12.count == ema26.count)
        let diff = zip(ema12, ema26).map(-)
        let deaEMA = EMACaculator(period: deaPeroid).process(diff)
        var result: [MACDIndicator] = []
        assert(diff.dropFirst(deaPeroid - 1).count == deaEMA.count)
        (0..<min(deaPeroid - 1, diff.count)).forEach {
            result.append(.init(diff: diff[$0], dea: nil, histogram: nil))
        }

        zip(diff.dropFirst(deaPeroid - 1), deaEMA).forEach {
            result.append(.init(diff: $0, dea: $1, histogram: $0 - $1))
        }
        return result
    }
}

extension MACDIndicator: CustomStringConvertible {
    public var description: String {
        "Diff: \(diff) DEA: \(dea?.description ?? "NAN") BAR: \(histogram?.description ?? "NAN")"
    }
}

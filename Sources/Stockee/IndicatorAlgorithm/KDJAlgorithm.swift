//
//  KDJAlgorithm.swift
//  Stockee
//
//  Created by octree on 2022/3/16.
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

/// KDJ 指标
public struct KDJIndicator: Equatable {
    // swiftlint:disable identifier_name
    public var k: CGFloat
    // swiftlint:disable identifier_name
    public var d: CGFloat
    // swiftlint:disable identifier_name
    public var j: CGFloat
}

/// 用于计算 KDJ 指标的算法
/// 目前 kPeriod 和 dPeriod 只支持 3、3
public struct KDJAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [KDJIndicator]
    /// 观察周期
    public let period: Int
    /// K 值平滑周期
    public let kPeriod: Int
    /// D 值平滑周期
    public let dPeriod: Int

    /// 创建一个计算 KDJ 指标的算法
    /// - Parameters:
    ///   - period: 观察周期，默认为 9
    ///   - kPeriod: K 值平滑周期，默认为 3
    ///   - dPeriod: D 值平滑周期，默认为 3
    public init(period: Int = 9, kPeriod: Int = 3, dPeriod: Int = 3) {
        self.period = period
        self.kPeriod = kPeriod
        self.dPeriod = dPeriod
    }

    /// 处理蜡烛图数据，生成 KDJ 数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: KDJ 数据
    public func process(_ data: [Input]) -> [KDJIndicator] {
        guard data.count >= period else { return [] }
        var result: [KDJIndicator] = []
        var prev: (k: CGFloat, d: CGFloat) = (50, 50)
        for index in (period - 1) ..< data.count {
            let (low, high) = lowHighPrice(of: data, in: (index - period + 1) ..< (index + 1))
            let rsv: CGFloat
            if high == low {
                rsv = 0
            } else {
                rsv = (data[index].close - low) / (high - low) * 100
            }
            let k = 1 / 3 * rsv + 2 / 3 * prev.k
            let d = 1 / 3 * k + 2 / 3 * prev.d
            let j = 3 * k - 2 * d
            result.append(.init(k: k, d: d, j: j))
            prev = (k, d)
        }
        return result
    }

    private func lowHighPrice(of data: [Input], in range: Range<Int>) -> (low: CGFloat, high: CGFloat) {
        assert(!range.isEmpty)
        var low = data[range.startIndex].low
        var high = data[range.startIndex].high
        data[range].forEach {
            if $0.high > high {
                high = $0.high
            }
            if $0.low < low {
                low = $0.low
            }
        }
        return (low, high)
    }
}

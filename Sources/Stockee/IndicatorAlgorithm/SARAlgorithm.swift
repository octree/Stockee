//
//  SARAlgorithm.swift
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

/// SAR 指标
public struct SARIndicator: Equatable {
    /// SAR 值
    public var sar: CGFloat
    /// 是否反转
    public var isReversal: Bool
    /// 是否是上升趋势
    public var isUp: Bool

    /// 创建一个 SAR 指标
    /// - Parameters:
    ///   - sar: SAR 指标值
    ///   - isReversal: 是否反转
    public init(sar: CGFloat, isReversal: Bool, isUp: Bool) {
        self.sar = sar
        self.isReversal = isReversal
        self.isUp = isUp
    }
}

/// 用于计算 SAR 指标的算法
/// SAR的计算公式分为上升式与下降式，即：
/// 上升式：SAR(n) = SAR(n-1) + AF[H(n-1) - SAR(n-1)]
/// 下降式：SAR(n) = SAR(n-1) + AF[L(n-1) - SAR (n-1)]
/// SAR(n-1) 表示前一日 SAR 值，其上升式初始值以近期最低价为准，其下降式初始值以近期最高价为准。
/// H 为当前最高价，L 为当前最低价。
/// AF—威尔特加速因子，基值为0.02，当价格每创新高(上升式)或新低(下降式)时，按1,2,3......倍数增加到0.2为止，即AF=0.02～0.2。
/// 上升趋势中 sar(n) > close(n) 时，则反转，进入下降趋势
/// 下降趋势中 sar(n) < close(n) 时，反转进入上升趋势
/// 数量：data.count - period + 1
public struct SARAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [SARIndicator]
    /// 基准周期
    public let period: Int
    /// 最小加速因子
    public let minAF: CGFloat
    /// 最大加速因子
    public let maxAF: CGFloat

    /// 创建一个计算 SAR 指标的算法
    /// - Parameters:
    ///   - period: 基准周期，默认为 4
    ///   - minAF: 最小加速因子，默认为 0.02
    ///   - maxAF: 最大加速因子，默认为 0.2
    public init(period: Int = 4, minAF: CGFloat = 0.02, maxAF: CGFloat = 0.2) {
        self.period = period
        self.minAF = minAF
        self.maxAF = maxAF
    }

    /// 处理蜡烛图数据，生成 SAR 数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: SAR 数据
    public func process(_ data: [Input]) -> [SARIndicator] {
        guard data.count > period else { return [] }
        var result: [SARIndicator] = []
        // 加速因子
        @AF(max: maxAF) var af: CGFloat = minAF
        var sar: CGFloat = 0
        let lowest = getLowestPriceOfCurrentPeriod(at: period - 1, data: data)
        let highest = getHighestPriceOfCurrentPeriod(at: period - 1, data: data)
        // 极点值
        var ep: CGFloat
        // 是否是上升趋势
        var isUp: Bool
        if data[period].close >= data[period - 1].close {
            isUp = true
            ep = highest
            sar = lowest
        } else {
            isUp = false
            ep = lowest
            sar = highest
        }
        result.append(.init(sar: sar, isReversal: true, isUp: isUp))
        for index in data.indices.dropFirst(period) {
            sar += af * (ep - sar)
            let isReversal = (isUp && data[index].close < sar)
                || (!isUp && data[index].close > sar)
            if isReversal {
                // 发生反转之后，重新获取 ep
                isUp.toggle()
                let lowest = getLowestPriceOfCurrentPeriod(at: index, data: data)
                let highest = getHighestPriceOfCurrentPeriod(at: index, data: data)
                sar = isUp ? lowest : highest
                ep = isUp ? highest : lowest
                _af.reset()
            } else {
                _af.increase(minAF)
                if isUp {
                    ep = getHighestPriceOfCurrentPeriod(at: index, data: data)
                } else {
                    ep = getLowestPriceOfCurrentPeriod(at: index, data: data)
                }
            }
            result.append(.init(sar: sar, isReversal: isReversal, isUp: isUp))
        }

        return result
    }

    private func getHighestPriceOfCurrentPeriod(at index: Int, data: [Input]) -> CGFloat {
        let lower = index - period + 1
        return data[lower...index].reduce(data[lower].high) { max($0, $1.high) }
    }

    private func getLowestPriceOfCurrentPeriod(at index: Int, data: [Input]) -> CGFloat {
        let lower = index - period + 1
        return data[lower...index].reduce(data[lower].low) { min($0, $1.low) }
    }
}

@propertyWrapper
final class AF {
    private var initial: CGFloat
    private var value: CGFloat
    private var max: CGFloat

    var wrappedValue: CGFloat {
        value
    }

    init(wrappedValue: CGFloat, max: CGFloat) {
        self.initial = wrappedValue
        self.value = wrappedValue
        self.max = max
    }

    func reset() {
        value = initial
    }

    func increase(_ delta: CGFloat) {
        value = min(max, value + delta)
    }
}

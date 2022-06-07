//
//  ExponentialMovingAverage.swift
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

/// 用于计算移 EMA 的算法
/// ```
/// Multiplier: (2 / (Time periods + 1) )
/// EMA: { Close - EMA(previous day) } * multiplier + EMA(previous day).
/// ```
///
/// * OKX 的 EMA，第一天取当天的收盘价，之后进行加权求值；
/// * 看了一些其他的解释，第 N 天使用前 N 天的 SMA，第 N + 1 天之后才进行 EMA 求值；
/// * 币安采用的后者，前 N 日是没有 EMA 数据的。
/// * 这里采用第二种方式计算
/// 所以返回的数据数量为：max(0, data.count - peroid + 1)
public struct ExponentialMovingAverageAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [CGFloat]
    /// EMA 计算周期
    public var period: Int {
        calculator.period
    }

    private let calculator: EMACaculator

    /// 创建一个 计算 EMA 指标的算法
    /// - Parameter period: MA 周期
    public init(period: Int) {
        self.calculator = .init(period: period)
    }

    /// 处理蜡烛图数据，生成 MA 数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: EMA 数据
    public func process(_ data: [Input]) -> [CGFloat] {
        calculator.process(data.map { $0.close })
    }
}

struct EMACaculator {
    public let period: Int
    private let multiplier: CGFloat

    init(period: Int) {
        self.period = period
        self.multiplier = 2 / CGFloat(period + 1)
    }

    func process(_ data: [CGFloat]) -> [CGFloat] {
        guard data.count >= period else { return [] }
        var prev: CGFloat = (data[0 ..< period].reduce(0) { $0 + $1 }) / CGFloat(period)
        var result: [CGFloat] = [prev]
        for value in data.dropFirst(period) {
            let ema = (value - prev) * multiplier + prev
            result.append(ema)
            prev = ema
        }
        return result
    }
}

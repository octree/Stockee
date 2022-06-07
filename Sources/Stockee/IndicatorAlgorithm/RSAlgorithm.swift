//
//  RSAlgorithm.swift
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

/// 用于计算 RS 指标的算法
/// 公式以 RS(14) 为例：
/// ```
/// RS = Average Gain / Average Loss
/// First Average Gain = Sum of Gains over the past 14 periods / 14.
/// First Average Loss = Sum of Losses over the past 14 periods / 14
/// Average Gain = [(previous Average Gain) x 13 + current Gain] / 14.
/// Average Loss = [(previous Average Loss) x 13 + current Loss] / 14.
/// ```
public struct RSAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [CGFloat]
    /// 基准周期
    public let period: Int

    /// 创建一个计算 RS 指标的算法
    /// - Parameters:
    ///   - period: 基准周期
    public init(period: Int) {
        self.period = period
    }

    /// 处理蜡烛图数据，生成 RS 数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: RS 数据
    public func process(_ data: [Input]) -> [CGFloat] {
        guard data.count >= period + 1 else { return [] }
        var result: [CGFloat] = []
        var upMoves: CGFloat = 0
        var downMoves: CGFloat = 0

        // 获取第一个 Average Gain 和 Average Loss
        for index in 1 ... period {
            let current = data[index].close
            let prev = data[index - 1].close
            if current >= prev {
                upMoves += current - prev
            } else {
                downMoves += prev - current
            }
        }
        let divisor = CGFloat(period)
        var averageGain = upMoves / divisor
        var averageLoss = downMoves / divisor
        result.append(averageGain / averageLoss)

        // 计算剩余的 RS 指标
        for index in (period + 1) ..< data.count {
            let current = data[index].close
            let prev = data[index - 1].close
            if current >= prev {
                averageGain = (averageGain * (divisor - 1) + current - prev) / divisor
                averageLoss = averageLoss * (divisor - 1) / divisor
            } else {
                averageLoss = (averageLoss * (divisor - 1) + prev - current) / divisor
                averageGain = averageGain * (divisor - 1) / divisor
            }
            result.append(averageGain / averageLoss)
        }
        return result
    }
}

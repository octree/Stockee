//
//  MovingAverage.swift
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

/// 用于计算移动平均线指标的算法，这里采用收盘价格进行计算
/// 返回数据的数量为 max(0, data.count - peroid + 1)
/// 例如：5 日 MA，如果数据是 [1, 2, 3]，则返回值为 []
/// 如果数据为 [1, 2, 3 , 4, 5], 则返回值为 [ 3 ]
public struct MovingAverageAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [CGFloat]
    /// MA 计算周期
    public let period: Int

    /// 创建一个 计算 MA 指标的算法
    /// - Parameter period: MA 周期
    public init(period: Int) {
        self.period = period
    }

    /// 处理蜡烛图数据，生成 MA 数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: MA 数据
    public func process(_ data: [Input]) -> [CGFloat] {
        guard data.count >= period else { return [] }
        var result: [CGFloat] = []
        var sum = data[0..<period].reduce(0) { $0 + $1.close }
        let divisor = CGFloat(period)
        result.append(sum / divisor)
        for index in period..<data.count {
            sum -= data[index &- period].close
            sum += data[index].close
            result.append(sum / divisor)
        }
        return result
    }
}

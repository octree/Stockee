//
//  RSIAlgorithm.swift
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

/// 用于计算 RSI 指标的算法
/// ```
///               100
/// RSI = 100 - --------
///              1 + RS
/// ```
public struct RSIAlgorithm<Input: Quote>: AnalysisAlgorithm {
    public typealias Output = [CGFloat]
    /// 基准周期
    public let period: Int

    /// 创建一个计算 RSI 指标的算法
    /// - Parameters:
    ///   - period: 基准周期
    public init(period: Int) {
        self.period = period
    }

    /// 处理蜡烛图数据，生成 RSI 数据
    /// - Parameter data: 蜡烛图数据
    /// - Returns: RSI 数据
    public func process(_ data: [Input]) -> [CGFloat] {
        RSAlgorithm(period: period).process(data).map {
            100 - 100 / (1 + $0)
        }
    }
}

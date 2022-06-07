//
//  IndicatorQuoteProcessor.swift
//  Stockee
//
//  Created by octree on 2022/3/18.
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

/// 把指标算法转换成 Renderer 可以使用的数据处理器
public struct IndicatorQuoteProcessor<Input, Element, Key, A>: QuoteProcessing
    where Element: ExtremePointValue, Key: ContextKey, Key.Value == ReadonlyOffsetArray<Element>, A: AnalysisAlgorithm, A.Output == [Element], A.Input == Input
{
    public typealias Input = Input
    public typealias Key = Key
    public typealias Output = ReadonlyOffsetArray<Element>
    public var identifier: Key?
    private var algorithm: A

    /// 根据指标算法，生成一个数据处理器
    /// - Parameters:
    ///   - id: 唯一的 id，如果传入 nil，则使用 Key.self 作为 id
    ///   - algorithm: 指标计算算法
    public init(id: Key? = nil, algorithm: A) {
        self.identifier = id
        self.algorithm = algorithm
    }

    public func process(_ data: [Input]) -> ReadonlyOffsetArray<Element> {
        let result = algorithm.process(data)
        return .init(result, offset: data.count - result.count)
    }
}

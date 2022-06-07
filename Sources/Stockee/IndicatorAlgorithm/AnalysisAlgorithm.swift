//
//  AnalysisAlgorithm.swift
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

/// 该协议，定义了一个技术分析算法应该包含的方法，以及输出类型
public protocol AnalysisAlgorithm {
    associatedtype Input: Quote
    associatedtype Output
    func process(_ data: [Input]) -> Output
}

/// 一个抹去类型的算法
public struct AnyAnalysisAlgorithm<Input: Quote> {
    var _process: ([Input]) -> Any

    /// 创建一个抹去类型的算法实例
    public init<A: AnalysisAlgorithm>(_ algorithm: A) where A.Input == Input {
        _process = { algorithm.process($0) }
    }
}

public extension AnalysisAlgorithm {
    /// Wraps this algorithm with a type eraser.
    var typeErased: AnyAnalysisAlgorithm<Input> {
        AnyAnalysisAlgorithm(self)
    }
}

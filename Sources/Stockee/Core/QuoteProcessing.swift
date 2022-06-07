//
//  QuoteProcessing.swift
//  Stockee
//
//  Created by Octree on 2022/3/17.
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

import UIKit

/// 用于处理
public protocol QuoteProcessing {
    associatedtype Input: Quote
    associatedtype Output
    associatedtype Key: ContextKey where Key.Value == Output

    /// 可以使用自定义 identifier，如果返回 nil，则会使用 Key.self 作为 identifier
    var identifier: Key? { get }
    func process(_ data: [Input]) -> Output
}

extension QuoteProcessing {
    public var identifier: Key? { nil }

    @inlinable
    var absoluteID: AnyHashable {
        if let id = identifier {
            return id
        } else {
            return ObjectIdentifier(Key.self)
        }
    }

    func process(_ data: [Input], writeTo contextValues: inout ContextValues) {
        contextValues[Key.self] = process(data)
    }
}

public struct AnyQuoteProcessor<Input> {
    private(set) var identifier: AnyHashable
    private var _process: ([Input]) -> Any

    public init<P: QuoteProcessing>(_ processor: P) where P.Input == Input {
        _process = { processor.process($0) }
        identifier = processor.absoluteID
    }

    func process(_ data: [Input], writeTo contextValues: inout ContextValues) {
        contextValues[identifier] = _process(data)
    }

    func clearValues(in contextValues: inout ContextValues) {
        contextValues[identifier] = nil
    }
}

extension QuoteProcessing {
    var typedErased: AnyQuoteProcessor<Input> { AnyQuoteProcessor(self) }
}

public enum NopeContextKey: ContextKey {
    public typealias Value = Void
}

// 一个什么都不做的处理器
public struct NopeQuoteProcessor<Input: Quote>: QuoteProcessing {
    public typealias Input = Input
    public typealias Output = Void
    public typealias Key = NopeContextKey
    public func process(_ data: [Input]) {}
}

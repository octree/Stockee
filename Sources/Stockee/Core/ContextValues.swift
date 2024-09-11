//
//  IndicatorKey.swift
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

import Foundation

/// 用于在 ``ContextValues`` 中接收值的 key
public protocol ContextKey: Hashable {
    associatedtype Value
}

/// 用于在 ``ContextValues`` 中接收交易信息
public enum QuoteContextKey<Input: Quote>: ContextKey {
    public typealias Value = [Input]
}

/// 用于向 ``ChartRenderer`` 传输一组数据
public struct ContextValues {
    private var values: [AnyHashable: Any] = [:]
    public subscript<Key: ContextKey>(key: Key.Type) -> Key.Value? {
        get {
            values[ObjectIdentifier(key)] as? Key.Value
        }
        _modify {
            var temp = values[ObjectIdentifier(key)] as? Key.Value
            yield &temp
            values[ObjectIdentifier(key)] = temp
        }
    }

    public subscript<Key: ContextKey>(key: Key) -> Key.Value? {
        get {
            values[key] as? Key.Value
        }
        _modify {
            var temp = values[key] as? Key.Value
            yield &temp
            values[key] = temp
        }
    }

    subscript(id: AnyHashable) -> Any? {
        _read {
            yield values[id]
        }
        _modify {
            yield &values[id]
        }
    }
}

//
//  ReadonlyOffsetArray.swift
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

import CoreGraphics
import Foundation

public struct ReadonlyOffsetArray<Element> {
    public let offset: Int
    var storage: [Element]

    /// 创建一个下标被偏移的数组
    ///
    /// realIndex = index - offset
    /// - Parameters:
    ///   - storage: 数据
    ///   - offset: 下标偏移量
    init(_ storage: [Element], offset: Int) {
        self.storage = storage
        self.offset = offset
    }

    public subscript(index: Int) -> Element? {
        let realIndex = index - offset
        guard realIndex >= 0, realIndex < storage.count else {
            return nil
        }
        return storage[realIndex]
    }
}

extension ReadonlyOffsetArray {
    func realRange(for range: Range<Int>) -> Range<Int> {
        ((range.lowerBound - offset)..<(range.upperBound - offset))
            .clamped(to: storage.startIndex..<storage.endIndex)
    }
}

extension ReadonlyOffsetArray {
    func sliceAndRange(for range: Range<Int>) -> (ArraySlice<Element>, Range<Int>) {
        let realRange = realRange(for: range)
        return (storage[realRange], realRange.startIndex + offset ..< realRange.endIndex + offset)
    }
}

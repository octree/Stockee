//
//  OffsetCollection+Indictaor.swift
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

public protocol ExtremePointValue {
    var min: CGFloat { get }
    var max: CGFloat { get }
}

extension BOLLIndicator: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat {
        Swift.min(lower, middle, upper)
    }

    @inline(__always)
    public var max: CGFloat {
        Swift.max(lower, middle, upper)
    }
}

extension KDJIndicator: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat {
        Swift.min(k, d, j)
    }

    @inline(__always)
    public var max: CGFloat {
        Swift.max(k, d, j)
    }
}

extension MACDIndicator: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat {
        [diff, dea, histogram].compactMap { $0 }.min()!
    }

    @inline(__always)
    public var max: CGFloat {
        [diff, dea, histogram].compactMap { $0 }.max()!
    }
}

extension SARIndicator: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat { sar }
    @inline(__always)
    public var max: CGFloat { sar }
}

extension CGFloat: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat { self }
    @inline(__always)
    public var max: CGFloat { self }
}

extension Double: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat { CGFloat(self) }
    @inline(__always)
    public var max: CGFloat { CGFloat(self) }
}

extension Int: ExtremePointValue {
    @inline(__always)
    public var min: CGFloat { CGFloat(self) }
    @inline(__always)
    public var max: CGFloat { CGFloat(self) }
}

extension ReadonlyOffsetArray: ExtremePointRetrievableCollection where Element: ExtremePointValue {
    public func extremePoint(in range: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        let realRange = ((range.lowerBound - offset)..<(range.upperBound - offset))
            .clamped(to: storage.startIndex..<storage.endIndex)
        guard !realRange.isEmpty else { return nil }
        let min = storage[realRange].map { $0.min }.min()!
        let max = storage[realRange].map { $0.max }.max()!
        return (min, max)
    }
}

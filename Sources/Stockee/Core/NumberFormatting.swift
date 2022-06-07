//
//  NumberFormatting.swift
//  Stockee
//
//  Created by octree on 2022/3/24.
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

public protocol NumberFormatting {
    func format(_ value: CGFloat) -> String
}

/// 默认的用来格式化价格的 Formatter
public struct DefaultPriceFormatter: NumberFormatting {
    /// 整数和小数位数有意义的数字的个数限制
    public var significantDigits: Int
    /// 小数位最小的长度
    public var minimumFractionDigits: Int

    /// 创建一个默认的价格的 Formatter
    /// - Parameters:
    ///   - significantDigits: 整数和小数位数有意义的数字的个数限制
    ///   - minimumFractionDigits: 小数位最小的长度
    public init(significantDigits: Int = 4, minimumFractionDigits: Int = 2) {
        self.significantDigits = significantDigits
        self.minimumFractionDigits = minimumFractionDigits
    }

    public func format(_ value: CGFloat) -> String {
        var integer = Int(value)
        var digits = 0
        while integer != 0 {
            digits += 1
            integer /= 10
        }
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = max(significantDigits, digits + minimumFractionDigits)
        formatter.numberStyle = .decimal
        return formatter.string(from: value as NSNumber)!
    }
}

/// 让 NumberFormatter 遵守 ``NumberFormatting`` 协议
extension NumberFormatter: NumberFormatting {
    public func format(_ value: CGFloat) -> String {
        string(from: value as NSNumber)!
    }
}

/// 默认的用来格式化交易量的 Formatter
public struct DefaultVolumeFormatter: NumberFormatting {
    private static var units = ["K", "M", "B", "T"]
    public func format(_ value: CGFloat) -> String {
        var unit = ""
        var value = value
        var units = Self.units
        while value >= 1000, units.count > 0 {
            value /= 1000
            unit = units.removeFirst()
        }
        let formatter = DefaultPriceFormatter(significantDigits: 2, minimumFractionDigits: 1)
        return "\(formatter.format(value))\(unit)"
    }
}

public extension NumberFormatting where Self == DefaultPriceFormatter {
    static func defaultPrice(significantDigits: Int = 4, minimumFractionDigits: Int = 2) -> DefaultPriceFormatter {
        .init(significantDigits: significantDigits,
              minimumFractionDigits: minimumFractionDigits)
    }
}

public extension NumberFormatting where Self == DefaultVolumeFormatter {
    static var volume: DefaultVolumeFormatter { .init() }
}

public extension NumberFormatting where Self == NumberFormatter {
    static func maximumFractionDigits(_ limit: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = limit
        formatter.numberStyle = .decimal
        return formatter
    }

    static func maximumSignificantDigits(_ limit: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = limit
        formatter.numberStyle = .decimal
        return formatter
    }
}

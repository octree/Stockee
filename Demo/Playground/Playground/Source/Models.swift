//
//  Models.swift
//  Stockee
//
//  Created by octree on 2022/4/8.
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

public struct ChartOption: OptionSet {
    public typealias RawValue = UInt
    public var rawValue: UInt

    public static var ma: ChartOption = .init(rawValue: 1 << 0)
    public static var ema: ChartOption = .init(rawValue: 1 << 1)
    public static var boll: ChartOption = .init(rawValue: 1 << 2)
    public static var sar: ChartOption = .init(rawValue: 1 << 3)
    public static var vol: ChartOption = .init(rawValue: 1 << 4)
    public static var kdj: ChartOption = .init(rawValue: 1 << 5)
    public static var rsi: ChartOption = .init(rawValue: 1 << 6)
    public static var macd: ChartOption = .init(rawValue: 1 << 7)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public extension ChartOption {
    init?(name: String) {
        switch name.lowercased() {
        case "ma":
            self = .ma
        case "ema":
            self = .ema
        case "boll":
            self = .boll
        case "sar":
            self = .sar
        case "vol":
            self = .vol
        case "kdj":
            self = .kdj
        case "rsi":
            self = .rsi
        case "macd":
            self = .macd
        default:
            return nil
        }
    }
}

//
//  SARTests.swift
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

@testable import Stockee
import XCTest

// 测试数据来自: 富途 FB 季 K 前 8 个数据
final class SARTests: XCTestCase {
    private let algorithm: SARAlgorithm<Candle> = .init()
    private var data: [Candle] = {
        // low, high, open, close
        [
            [25.520, 45.0, 42.050, 31.095],
            [17.550, 32.880, 31.250, 21.660],
            [18.800, 28.880, 22.080, 26.620],
            [24.720, 32.506, 27.440, 25.580],
            [22.670, 29.070, 25.630, 24.880],
            [24.150, 51.600, 24.969, 50.230],
            [43.550, 58.580, 49.970, 54.649],
            [51.850, 72.590, 54.830, 60.240]
        ].map { .init(low: $0[0], high: $0[1], open: $0[2], close: $0[3]) }
    }()

    private var sar: [SARIndicator] = [
        .init(sar: 45.0, isReversal: true, isUp: false),
        .init(sar: 44.451, isReversal: false, isUp: false),
        .init(sar: 18.800, isReversal: true, isUp: true),
        .init(sar: 19.456, isReversal: false, isUp: true),
        .init(sar: 21.021, isReversal: false, isUp: true)
    ]

    func testWithEmptyData() {
        XCTAssertTrue(algorithm.process([]).count == 0)
    }

    func testWith4Items() {
        let data = Array(data[0 ..< 4])
        XCTAssertTrue(algorithm.process(data).count == 0)
    }

    func testWith5Items() {
        let data = Array(data[0 ..< 5])
        XCTAssertEqual(algorithm.process(data), Array(sar[0 ..< 2]))
    }

    func testWithAllData() {
        let result = algorithm.process(data)
        XCTAssertEqual(result.count, sar.count)
        zip(result, sar).forEach { elt, expected in
            XCTAssertEqual(elt.sar, expected.sar, accuracy: 0.001)
            XCTAssertEqual(elt.isReversal, expected.isReversal)
        }
    }

    func testPerformance() {
        let data: [Candle] = (0 ..< 1000).map { _ in
            let low = CGFloat.random(in: 10 ... 20)
            let high = CGFloat.random(in: 40 ... 50)
            let open = CGFloat.random(in: low ..< high)
            let close = CGFloat.random(in: low ..< high)
            return .init(low: low, high: high, open: open, close: close)
        }
        measure {
            _ = algorithm.process(data)
        }
    }
}

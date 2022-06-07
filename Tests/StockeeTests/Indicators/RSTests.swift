//
//  RSTests.swift
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

@testable import Stockee
import XCTest

/// Test case from https://school.stockcharts.com/doku.php?id=technical_indicators:relative_strength_index_rsi
final class RSTests: XCTestCase {
    private let algorithm: RSAlgorithm = RSAlgorithm<Candle>(period: 14)
    private var data: [Candle] = {
        [44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08, 45.89, 46.03, 45.61, 46.28, 46.28, 46.00, 46.03, 46.41, 46.22, 45.64, 46.21, 46.25, 45.71, 46.45]
            .map { .init(close: $0) }
    }()

    private var rs: [CGFloat] = [2.39, 1.97, 1.99, 2.27, 1.97, 1.38, 1.70, 1.72, 1.28, 1.66]

    func testWithEmpty() {
        XCTAssertTrue(algorithm.process([]).isEmpty)
    }

    public func testWithInsufficientDataSet() {
        let data: [Candle] = Array(data[0 ..< 14])
        XCTAssertTrue(algorithm.process(data).isEmpty)
    }

    public func testWithFitDataSet() {
        let data: [Candle] = Array(data[0 ..< 15])
        XCTAssertEqual(algorithm.process(data).map { $0.rounded }, [2.39])
    }

    public func testWithMoreData() {
        func eq(_ x: CGFloat, _ y: CGFloat) -> Bool {
            abs(x - y) < 0.01
        }
        XCTAssertTrue(
            zip(algorithm.process(data), rs).allSatisfy(eq)
        )
    }
}

//
//  EMATests.swift
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

@testable import Stockee
import XCTest

/// Test case from https://school.stockcharts.com/doku.php?id=technical_indicators:moving_averages
final class EMATests: XCTestCase {
    private let algorithm: ExponentialMovingAverageAlgorithm<Candle> = .init(period: 10)

    func testWithEmpty() {
        XCTAssertTrue(algorithm.process([]).isEmpty)
    }

    public func testWithInsufficientDataSet() {
        let data: [Candle] = (0 ..< 4).map { _ in .init() }
        XCTAssertTrue(algorithm.process(data).isEmpty)
    }

    public func testWithFitDataSet() {
        let data: [Candle] = [22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24, 22.29]
            .map {
                Candle(close: $0)
            }
        XCTAssertEqual(algorithm.process(data).map { $0.rounded }, [22.22])
    }

    public func testWithMoreData() {
        let data: [Candle] = [22.27, 22.19, 22.08, 22.17, 22.18, 22.13, 22.23, 22.43, 22.24, 22.29, 22.15, 22.39, 22.38, 22.61, 23.36]
            .map {
                Candle(close: $0)
            }
        let expected: [CGFloat] = [22.22, 22.21, 22.24, 22.27, 22.33, 22.52]
        XCTAssertEqual(algorithm.process(data).map { $0.rounded }, expected)
    }
}

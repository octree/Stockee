//
//  BOLLTests.swift
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

/// Test case from https://school.stockcharts.com/doku.php?id=technical_indicators:bollinger_bands
final class BOLLTests: XCTestCase {
    private let algorithm: BollingerBandsAlgorithm<Candle> = .init()
    private var data: [Candle] = {
        [90.70, 92.90, 92.98, 91.80, 92.66, 92.68, 92.30, 92.77, 92.54, 92.95, 93.20, 91.07, 89.83, 89.74, 90.40, 90.74, 88.02, 88.09, 88.84, 90.78, 90.54, 91.39, 90.65]
            .map { .init(close: $0) }
    }()

    func testWithEmpty() {
        XCTAssertTrue(algorithm.process([]).isEmpty)
    }

    public func testWithInsufficientDataSet() {
        let data: [Candle] = (0 ..< 4).map { _ in .init() }
        XCTAssertTrue(algorithm.process(data).isEmpty)
    }

    public func testWithFitDataSet() {
        let data: [Candle] = Array(self.data[0 ..< 20])
        let expected: [BOLLIndicator] = [
            .init(lower: 87.97, middle: 91.25, upper: 94.53)
        ]
        XCTAssertEqual(algorithm.process(data).map { $0.rounded }, expected)
    }

    public func testWithMoreData() {
        let expected: [BOLLIndicator] = [
            .init(lower: 87.97, middle: 91.25, upper: 94.53),
            .init(lower: 87.95, middle: 91.24, upper: 94.53),
            .init(lower: 87.96, middle: 91.17, upper: 94.37),
            .init(lower: 87.95, middle: 91.05, upper: 94.15)
        ]
        XCTAssertEqual(algorithm.process(data).map { $0.rounded }, expected)
    }
}

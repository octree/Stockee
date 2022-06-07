//
//  File.swift
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

// 测试数据来自：https://investexcel.net/how-to-calculate-macd-in-excel/
final class MACDTests: XCTestCase {
    private let algorithm: MACDAlgorithm<Candle> = .init()
    private var data: [Candle] = {
        [459.99, 448.85, 446.06, 450.81, 442.8, 448.97, 444.57, 441.4, 430.47, 420.05, 431.14, 425.66, 430.58, 431.72, 437.87, 428.43, 428.35, 432.5, 443.66, 455.72, 454.49, 452.08, 452.73, 461.91, 463.58, 461.14, 452.08, 442.66, 428.91, 429.79, 431.99, 427.72, 423.2, 426.21, 426.98, 435.69, 434.33, 429.8, 419.85, 426.24, 402.8]
            .map { .init(close: $0) }
    }()

    private var macd: [MACDIndicator] = {
        [[8.2752695],
         [7.7033784],
         [6.4160748],
         [4.2375198],
         [2.5525833],
         [1.3788857],
         [0.1029815],
         [-1.258402],
         [-2.070558, 3.0375259, -5.108084059],
         [-2.621842, 1.9056522, -4.527494558],
         [-2.329067, 1.0587084, -3.387775176],
         [-2.181632, 0.4106403, -2.59227244],
         [-2.402626, -0.152013, -2.250613279],
         [-3.342122, -0.790035, -2.55208695],
         [-3.530363, -1.3381, -2.192262723],
         [-5.507471, -2.171975, -3.335496669]]
            .map {
                $0.count > 1 ? .init(diff: $0[0], dea: $0[1], histogram: $0[2]) : .init(diff: $0[0], dea: nil, histogram: nil)
            }
    }()

    func testWithEmpty() {
        XCTAssertTrue(algorithm.process([]).isEmpty)
    }

    public func testWithInsufficientDataSet() {
        let data: [Candle] = Array(data[0 ..< 25])
        XCTAssertTrue(algorithm.process(data).isEmpty)
    }

    public func testWithFitDataSet() {
        let data: [Candle] = Array(data[0 ..< 26])
        let result = algorithm.process(data)
        XCTAssertTrue(result.count == 1)
        XCTAssertEqual(result[0].diff, macd[0].diff, accuracy: 0.00001)
        XCTAssertNil(result[0].dea)
        XCTAssertNil(result[0].histogram)
    }

    public func testWith33Items() {
        let data: [Candle] = Array(data[0 ..< 33])
        let result = algorithm.process(data)
        XCTAssertTrue(result.count == 8)
        result.indices.forEach {
            XCTAssertEqual(result[$0].diff, macd[$0].diff, accuracy: 0.00001)
            XCTAssertNil(result[$0].dea)
            XCTAssertNil(result[$0].histogram)
        }
    }

    public func testWith34Items() {
        let data: [Candle] = Array(data[0 ..< 34])
        let result = algorithm.process(data)
        XCTAssertTrue(result.count == 9)
        XCTAssertEqual(result[8].diff, macd[8].diff, accuracy: 0.00001)
        XCTAssertNotNil(result[8].dea)
        XCTAssertNotNil(result[8].histogram)
        XCTAssertEqual(result[8].dea!, macd[8].dea!, accuracy: 0.00001)
        XCTAssertEqual(result[8].histogram!, macd[8].histogram!, accuracy: 0.00001)
    }

    public func testWithMoreData() {
        let result = algorithm.process(data)
        XCTAssertEqual(result.count, macd.count)
        zip(result, macd).forEach {
            switch ($0.0.histogram, $0.1.histogram) {
            case let (.some(lhs), .some(rhs)):
                XCTAssertEqual(lhs, rhs, accuracy: 0.00001)
            case (.none, .none):
                break
            default:
                XCTAssertTrue(false)
            }
        }
    }
}

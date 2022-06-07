//
//  AnyChartRendererTests.swift
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

final class AnyChartRendererTests: XCTestCase {
    func testAnyEqual1() {
        let any1 = AnyChartRenderer(CounterRenderer())
        XCTAssertEqual(any1, any1)
    }

    func testAnyEqual2() {
        let renderer = CounterRenderer()
        let any1 = AnyChartRenderer(renderer)
        let any2 = AnyChartRenderer(renderer)
        XCTAssertEqual(any1, any2)
    }

    func testHasble1() {
        let renderer = CounterRenderer()
        let any1 = AnyChartRenderer(renderer)
        let any2 = AnyChartRenderer(renderer)
        XCTAssertEqual(Set([any1, any2]).count, 1)
    }

    func testHasble2() {
        let any1 = AnyChartRenderer(CounterRenderer())
        let any2 = AnyChartRenderer(CounterRenderer())
        XCTAssertEqual(Set([any1, any2]).count, 2)
    }

    func testNotEqual1() {
        let any1 = AnyChartRenderer(CounterRenderer())
        let any2 = AnyChartRenderer(CounterRenderer())
        XCTAssertNotEqual(any1, any2)
    }

    func testNotEqual2() {
        let any1 = AnyChartRenderer(CounterRenderer())
        let any2 = AnyChartRenderer(AverageRenderer())
        XCTAssertNotEqual(any1, any2)
    }
}

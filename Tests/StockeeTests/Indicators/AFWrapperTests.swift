//
//  AFWrapperTests.swift
//  Stockee
//
//  Created by octree on 2022/3/17.
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

@testable import Stockee
import XCTest

final class AFWrapperTests: XCTestCase {
    func testInitialValue() {
        @AF(max: 0.2) var af: CGFloat = 0.02
        XCTAssertEqual(af, 0.02)
    }

    func testIncrease() {
        @AF(max: 0.2) var af: CGFloat = 0.02
        _af.increase(0.02)
        XCTAssertEqual(af, 0.04)
        _af.increase(0.02)
        XCTAssertEqual(af, 0.06)
    }

    func testIncreaseOverflow() {
        @AF(max: 0.2) var af: CGFloat = 0.02
        (0 ... 10).forEach { _ in _af.increase(10) }
        XCTAssertEqual(af, 0.2)
    }

    func testReset() {
        @AF(max: 0.2) var af: CGFloat = 0.02
        _af.increase(0.02)
        _af.reset()
        XCTAssertEqual(af, 0.02)
    }
}

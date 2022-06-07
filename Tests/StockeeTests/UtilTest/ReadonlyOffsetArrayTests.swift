//
//  ReadonlyOffsetArray.swift
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

final class ReadonlyOffsetArrayTests: XCTestCase {
    private let array = ReadonlyOffsetArray([1, 2, 3, 4], offset: 3)

    func test() {
        XCTAssertEqual(array[0], nil)
        XCTAssertEqual(array[2], nil)
        XCTAssertEqual(array[3], 1)
        XCTAssertEqual(array[6], 4)
        XCTAssertEqual(array[7], nil)
    }

    func testExtremePoint() {
        XCTAssertTrue(array.extremePoint(in: 0 ..< 2) == nil)
        XCTAssertTrue(array.extremePoint(in: 3 ..< 3) == nil)
        XCTAssertTrue(array.extremePoint(in: 4 ..< 4) == nil)
        var result = array.extremePoint(in: 0 ..< 10)
        XCTAssertTrue(result?.min == 1 && result?.max == 4)
        result = array.extremePoint(in: 5 ..< 8)
        XCTAssertTrue(result?.min == 3 && result?.max == 4)
        result = array.extremePoint(in: 3 ..< 5)
        XCTAssertTrue(result?.min == 1 && result?.max == 2)
    }
}

//
//  ContextValuesTests.swift
//  Stockee
//
//  Created by octree on 2022/4/12.
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


final class ContextValuesTests: XCTestCase {

    enum Key: ContextKey {
        typealias Value = Int
        case key
    }


    func testWithTypeAsKey() {
        var values = ContextValues()
        XCTAssertTrue(values[Key.self] == nil)
        values[Key.self] = 1
        XCTAssertTrue(values[Key.self] == 1)
        values[Key.self] = nil
        XCTAssertTrue(values[Key.self] == nil)
    }

    func testWithCaseAsKey() {
        var values = ContextValues()
        XCTAssertTrue(values[Key.key] == nil)
        values[Key.key] = 1
        XCTAssertTrue(values[Key.key] == 1)
        values[Key.key] = nil
        XCTAssertTrue(values[Key.key] == nil)
    }

    func testWithAnyHashable() {
        var values = ContextValues()
        XCTAssertTrue(values[1] == nil)
        values[1] = 1
        XCTAssertTrue((values[1] as? Int) == 1)
        values[1] = nil
        XCTAssertTrue(values[1] == nil)
    }
}

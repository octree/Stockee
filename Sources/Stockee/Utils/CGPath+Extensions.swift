//
//  CGPath+Extensions.swift
//  Stockee
//
//  Created by octree on 2022/3/20.
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

import CoreGraphics
import Foundation

extension CGPath {
    static func lineSegments(with points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        return path
    }

    private static func directionVector(from: CGPoint, to: CGPoint) -> CGVector {
        .init(dx: to.x - from.x, dy: to.y - from.y)
            .normalized ?? CGVector(dx: 1, dy: 0)
    }

    static func smoothCurve(with points: [CGPoint], granularity: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let count = points.count
        guard count > 1 else { return path }
        var preVector = CGVector(dx: 1, dy: 0)
        var currentVector: CGVector = .zero

        func addCurve(from: CGPoint, to: CGPoint) {
            let distance = (to - from).norm
            let controlP1 = from + preVector * distance * granularity
            let controlP2 = to - currentVector * distance * granularity
            path.addCurve(to: to, control1: controlP1, control2: controlP2)
        }
        path.move(to: points[0])
        for index in 1 ..< (count - 1) {
            currentVector = directionVector(from: points[index - 1], to: points[index + 1])
            defer { preVector = currentVector }
            addCurve(from: points[index - 1], to: points[index])
        }
        currentVector = .init(dx: 1, dy: 0)
        addCurve(from: points[count - 2], to: points[count - 1])
        return path
    }
}

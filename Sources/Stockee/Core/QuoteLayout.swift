//
//  QuoteLayout.swift
//
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

import UIKit

/// 用于计算每个 Bar 横向位置的类
public struct QuoteLayout<Input: Quote> {
    unowned var view: ChartView<Input>
    private var configuration: Configuration { view.scaledConfiguration }

    init(_ view: ChartView<Input>) {
        self.view = view
    }

    public func contentWidth(for data: [Input]) -> CGFloat {
        let width = view.frame.width - view.contentInset.left - view.contentInset.right
        guard data.count > 0 else { return width }
        let contentWidth = (configuration.barWidth + configuration.spacing) * CGFloat(data.count) - configuration.spacing
        return max(width, contentWidth)
    }

    public func visibleRange() -> Range<Int> {
        guard view.data.count > 0 else { return .none }
        let minX = view.contentOffset.x
        let maxX = minX + view.frame.width
        let thunkWidth = configuration.barWidth + configuration.spacing
        let minIndex = min(view.data.count, max(0, Int(minX / thunkWidth)))
        let maxIndex = max(0, min(view.data.count, Int(maxX / thunkWidth) + 1))
        return minIndex ..< maxIndex
    }

    public func contentRectToDraw(visibleRange: Range<Int>, y: CGFloat, height: CGFloat) -> CGRect {
        guard !visibleRange.isEmpty else { return CGRect(x: 0, y: y, width: 0, height: height) }
        let thunkWidth = configuration.barWidth + configuration.spacing
        let minX = CGFloat(visibleRange.startIndex) * thunkWidth
        let maxX = CGFloat(visibleRange.endIndex - 1) * thunkWidth
        return CGRect(x: minX, y: y, width: maxX - minX, height: height)
    }
}

public extension QuoteLayout {
    var barWidth: CGFloat {
        configuration.barWidth
    }

    var spacing: CGFloat {
        configuration.spacing
    }

    func quoteMinX(at index: Int) -> CGFloat {
        let thunkWidth = configuration.barWidth + configuration.spacing
        return thunkWidth * CGFloat(index)
    }

    func quoteMidX(at index: Int) -> CGFloat {
        let thunkWidth = configuration.barWidth + configuration.spacing
        return thunkWidth * CGFloat(index) + configuration.barWidth / 2
    }

    func quoteMaxX(at index: Int) -> CGFloat {
        let thunkWidth = configuration.barWidth + configuration.spacing
        return thunkWidth * CGFloat(index) + configuration.barWidth
    }

    func quoteIndex(at point: CGPoint) -> Int? {
        let thunkWidth = configuration.barWidth + configuration.spacing
        let index = Int(point.x / thunkWidth)
        guard index >= 0, index < view.data.count else { return nil }
        return index
    }

    func horizontalGridCount(width: CGFloat) -> Int {
        max(1, Int(width / configuration.gridInterval.h))
    }

    func verticalGridCount(heigt: CGFloat) -> Int {
        max(1, Int(heigt / configuration.gridInterval.v))
    }
}

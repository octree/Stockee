//
//  GridIndicator.swift
//  Stockee
//
//  Created by octree on 2022/3/22.
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

/// 用于绘制 ChartGroup 的网格
public class GridIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private let layer = GridLayer()

    /// 创建网格
    /// - Parameters:
    ///   - lineWidth: 网格线的粗细，默认为 1px
    ///   - color: 网格线的颜色
    public init(lineWidth: CGFloat = 1 / UIScreen.main.scale, color: UIColor) {
        layer.lineWidth = lineWidth
        layer.strokeColor = color.cgColor
    }

    public func updateZPosition(_ position: CGFloat) {
        layer.zPosition = position
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(layer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        layer.draw(in: context)
    }

    public func tearDown(in view: ChartView<Input>) {
        layer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

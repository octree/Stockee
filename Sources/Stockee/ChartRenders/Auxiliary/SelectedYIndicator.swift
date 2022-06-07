//
//  SelectedYIndicator.swift
//  Stockee
//
//  Created by octree on 2022/4/8.
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

/// 用于绘制当前滑动选择的 Y 轴的值
public class SelectedYIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var label: IndicatorLabel = .init()
    private var height: CGFloat
    private var minWidth: CGFloat
    private var maxWidth: CGFloat

    /// 正在选择的 Y 轴的指示器
    /// - Parameters:
    ///   - height: 高度
    ///   - minWidth: 最小宽度
    ///   - maxWidth: 最大宽度
    ///   - background: 背景颜色
    ///   - textColor: 文字颜色
    public init(height: CGFloat = 12,
                minWidth: CGFloat = 36,
                maxWidth: CGFloat = 80,
                background: UIColor = .red,
                textColor: UIColor = .white)
    {
        self.height = height
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        label.shapeLayer.fillColor = background.cgColor
        label.label.textColor = textColor
    }

    public func updateZPosition(_ position: CGFloat) {
        label.layer.zPosition = .greatestFiniteMagnitude
    }

    public func setup(in view: ChartView<Input>) {
        view.addSubview(label)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        let minY = context.groupContentRect.minY
        let maxY = context.groupContentRect.maxY
        guard context.extremePoint.max - context.extremePoint.min > 0,
              let position = context.indicatorPosition,
              position.y >= minY, position.y <= maxY
        else {
            label.isHidden = true
            return
        }
        let y = position.y
        label.isHidden = false
        label.label.font = context.configuration.captionFont
        let minX = view.contentOffset.x
        let maxX = minX + view.frame.width
        let midX = (minX + maxX) / 2
        let value = context.value(forY: y)
        label.label.text = context.preferredFormatter.format(value)
        var size = label.sizeThatFits(.init(width: maxWidth, height: height))
        size.height = height
        size.width = min(maxWidth, max(size.width, minWidth))
        if position.x > midX {
            label.triangleDirection = .left
            label.frame = CGRect(origin: CGPoint(x: maxX - size.width, y: y - size.height / 2),
                                 size: size)
        } else {
            label.triangleDirection = .right
            label.frame = CGRect(origin: CGPoint(x: minX, y: y - size.height / 2),
                                 size: size)
        }
    }

    public func tearDown(in view: ChartView<Input>) {
        label.removeFromSuperview()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

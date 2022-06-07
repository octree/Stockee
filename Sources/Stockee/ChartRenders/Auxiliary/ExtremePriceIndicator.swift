//
//  ExtremePriceIndicator.swift
//  Stockee
//
//  Created by octree on 2022/3/28.
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

/// 用于显示最高价和最低价的指示器
public final class ExtremePriceIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var hLabel: UILabel = .init()
    private var lLabel: UILabel = .init()
    private var layer: ShapeLayer = {
        let shape = ShapeLayer()
        shape.lineWidth = 1 / UIScreen.main.scale
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()

    private var lineWidth: CGFloat = 10
    private var color: UIColor
    public init(color: UIColor) {
        self.color = color
    }

    public func updateZPosition(_ position: CGFloat) {
        layer.zPosition = position
        hLabel.layer.zPosition = position
        lLabel.layer.zPosition = position
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(layer)
        view.addSubview(hLabel)
        view.addSubview(lLabel)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        let range = context.visibleRange
        guard !range.isEmpty else {
            clear()
            return
        }
        var maxIndex = range.first!
        var minIndex = range.first!
        for idx in range.dropFirst() {
            if context.data[idx].high > context.data[maxIndex].high {
                maxIndex = idx
            }
            if context.data[idx].low < context.data[minIndex].low {
                minIndex = idx
            }
        }
        let path = CGMutablePath()
        setupIndicator(for: context.data[maxIndex].high,
                       at: maxIndex,
                       in: context,
                       writeTo: path,
                       label: hLabel)
        setupIndicator(for: context.data[minIndex].low,
                       at: minIndex,
                       in: context,
                       writeTo: path,
                       label: lLabel)
        layer.path = path
        layer.strokeColor = color.cgColor
    }

    public func tearDown(in view: ChartView<Input>) {
        layer.removeFromSuperlayer()
        hLabel.removeFromSuperview()
        lLabel.removeFromSuperview()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }

    private func clear() {
        layer.path = nil
        hLabel.text = nil
        lLabel.text = nil
    }

    private func setupIndicator(for value: CGFloat,
                                at index: Int,
                                in context: Context,
                                writeTo path: CGMutablePath,
                                label: UILabel)
    {
        let midX = context.layout.quoteMidX(at: index)
        let sign: CGFloat = context.contentRect.midX > midX ? 1 : -1
        let y = context.yOffset(for: value)
        let x2 = midX + sign * lineWidth
        label.text = context.preferredFormatter.format(value)
        label.textColor = color
        label.font = context.configuration.captionFont
        label.sizeToFit()
        label.center = CGPoint(x: x2 + sign * label.frame.width / 2,
                               y: y)
        path.move(to: CGPoint(x: midX, y: y))
        path.addLine(to: CGPoint(x: x2, y: y))
    }
}

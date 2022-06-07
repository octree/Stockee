//
//  LatestPriceIndicator.swift
//  Stockee
//
//  Created by octree on 2022/4/6.
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

/// 用于绘制最新成交价格
public class LatestPriceIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var label: IndicatorLabel = .init()
    private var layer: ShapeLayer = {
        let layer = ShapeLayer()
        layer.lineWidth = 1
        layer.fillColor = UIColor.clear.cgColor
        layer.lineDashPattern = [2, 2]
        return layer
    }()

    private var height: CGFloat
    private var minWidth: CGFloat
    private var maxWidth: CGFloat

    /// 最新成交价的指示器
    /// - Parameters:
    ///   - height: Label 高度
    ///   - minWidth: 最小宽度
    ///   - maxWidth: Label 最大宽度
    ///   - textColor: 文字颜色，默认白色
    public init(height: CGFloat = 12,
                minWidth: CGFloat = 36,
                maxWidth: CGFloat = 80,
                textColor: UIColor = .white) {
        self.height = height
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        label.label.textColor = textColor
    }

    public func updateZPosition(_ position: CGFloat) {
        layer.zPosition = position
        label.layer.zPosition = position
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(layer)
        view.addSubview(label)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        guard let last = context.data.last else {
            layer.isHidden = true
            label.isHidden = true
            return
        }
        layer.isHidden = false
        label.isHidden = false
        let style = context.configuration.style
        let color = last.close > last.open ? style.upColor : style.downColor
        layer.strokeColor = color.cgColor
        label.shapeLayer.fillColor = color.cgColor
        label.label.font = context.configuration.captionFont
        label.label.text = context.preferredFormatter.format(last.close)

        let y = context.yOffset(for: last.close)
        var size = label.sizeThatFits(.init(width: maxWidth, height: height))
        size.width = min(maxWidth, max(size.width, minWidth))
        size.height = height
        let maxX = view.contentOffset.x + view.frame.width
        let minY = context.contentRect.minY
        let maxY = context.groupContentRect.maxY
        var frame = CGRect(origin: CGPoint(x: maxX - size.width, y: y - height / 2),
                           size: size)
        frame.origin.y = min(max(frame.origin.y, minY), maxY - height)
        label.frame = frame
        let path = CGMutablePath()
        let midY = frame.midY
        path.move(to: .init(x: view.contentOffset.x, y: midY))
        path.addLine(to: .init(x: maxX, y: midY))
        layer.path = path
    }

    public func tearDown(in view: ChartView<Input>) {
        layer.removeFromSuperlayer()
        label.removeFromSuperview()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

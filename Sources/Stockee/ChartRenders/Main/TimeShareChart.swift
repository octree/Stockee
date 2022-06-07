//
//  TimeShareChart.swift
//  Stockee
//
//  Created by octree on 2022/3/31.
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

/// 分时图
public final class TimeShareChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    /// 颜色
    public var color: UIColor {
        didSet {
            updateGradientColor()
        }
    }

    private var timeShareLayer: TimeShareLayer = .init()

    /// 创建蜡烛图图表
    /// - Parameter color: 颜色
    public init(color: UIColor) {
        self.color = color
        updateGradientColor()
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(timeShareLayer)
    }

    public func updateZPosition(_ position: CGFloat) {
        timeShareLayer.zPosition = position
    }

    public func render(in view: ChartView<Input>, context: Context) {
        timeShareLayer.update(with: context)
    }

    public func tearDown(in view: ChartView<Input>) {
        timeShareLayer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        guard let data = contextValues[QuoteContextKey<Input>.self],
              data[visibleRange].count > 0
        else {
            return nil
        }
        let min = data[visibleRange].map { $0.low }.min()!
        let max = data[visibleRange].map { $0.high }.max()!
        return (min, max)
    }

    // MARK: - Private Methods

    private func updateGradientColor() {
        timeShareLayer.update(color: color)
    }

    public func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        let quote = context.data[quoteIndex]
        let text = context.preferredFormatter.format(quote.close)
        let color = quote.close > quote.open ? context.configuration.upColor : context.configuration.downColor
        return [
            .init(string: "Price:\(text)",
                  attributes: [
                      .font: context.configuration.captionFont,
                      .foregroundColor: color
                  ])
        ]
    }
}

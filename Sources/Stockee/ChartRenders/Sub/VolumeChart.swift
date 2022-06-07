//
//  VolumeChart.swift
//  Stockee
//
//  Created by octree on 2022/3/21.
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

/// 交易量图表
public final class VolumeChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    public let minHeight: CGFloat

    private var upLayer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()

    private var downLayer: ShapeLayer = {
        let layer = ShapeLayer()
        return layer
    }()

    /// 创建交易量图表
    /// - Parameter minHeight: 最低高度，默认 1pt
    public init(minHeight: CGFloat = 1) { self.minHeight = minHeight }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(upLayer)
        view.layer.addSublayer(downLayer)
    }

    public func updateZPosition(_ position: CGFloat) {
        upLayer.zPosition = position
        downLayer.zPosition = position
    }

    public func render(in view: ChartView<Input>, context: Context) {
        let data = context.contextValues[QuoteContextKey<Input>.self] ?? []
        upLayer.fillColor = context.configuration.upColor.cgColor
        downLayer.fillColor = context.configuration.downColor.cgColor
        let upPath = CGMutablePath()
        let downPath = CGMutablePath()
        for index in context.visibleRange {
            let quote = data[index]
            if quote.open > quote.close {
                writePath(into: downPath, data: data, context: context, index: index)
            } else {
                writePath(into: upPath, data: data, context: context, index: index)
            }
        }

        upLayer.path = upPath
        downLayer.path = downPath
    }

    public func tearDown(in view: ChartView<Input>) {
        upLayer.removeFromSuperlayer()
        downLayer.removeFromSuperlayer()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        guard let data = contextValues[QuoteContextKey<Input>.self],
              data[visibleRange].count > 0
        else {
            return nil
        }
        let min = data[visibleRange].map { $0.volume }.min()!
        let max = data[visibleRange].map { $0.volume }.max()!
        return (min, max)
    }

    public func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        let quote = context.data[quoteIndex]
        let text = context.preferredFormatter.format(quote.volume)
        let color = quote.close > quote.open ? context.configuration.upColor : context.configuration.downColor
        return [
            .init(string: "VOL:\(text)",
                  attributes: [
                      .font: context.configuration.captionFont,
                      .foregroundColor: color
                  ])
        ]
    }
}

private extension VolumeChart {
    private func writePath(into path: CGMutablePath,
                           data: [Input],
                           context: RendererContext<Input>,
                           index: Int)
    {
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        let quote = data[index]
        let barX = (barWidth + spacing) * CGFloat(index)
        let barRect = rect(for: quote,
                           x: _pixelCeil(barX),
                           width: barWidth,
                           context: context)
        path.addRect(barRect)
    }

    private func rect(for quote: Input, x: CGFloat, width: CGFloat, context: Context) -> CGRect {
        let maxY = context.contentRect.maxY
        let y = Swift.min(yOffset(for: quote.volume, context: context), maxY - minHeight)
        let height = maxY - y
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func yOffset(for price: CGFloat, context: Context) -> CGFloat {
        let height = context.contentRect.height
        let minY = context.contentRect.minY
        let peak = context.extremePoint.max - context.extremePoint.min
        return height - height * (price - context.extremePoint.min) / peak + minY
    }
}

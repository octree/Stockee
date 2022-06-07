//
//  MACDChart.swift
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

/// MACD 配置信息
public struct MACDConfiguration: ContextKey {
    public typealias Value = ReadonlyOffsetArray<MACDIndicator>
    public var shorterPeroid: Int
    public var longerPeroid: Int
    public var deaPeroid: Int
    public var diffColor: UIColor
    public var deaColor: UIColor
    public var minBarHeight: CGFloat

    /// 创建一个 MACD 配置信息，默认为 MACD(12, 26, 9)
    /// - Parameters:
    ///   - shorterPeroid: 短期周期
    ///   - longerPeroid: 长期周期
    ///   - deaPeroid: EMA(Diff) 周期
    ///   - diffColor: Diff 折线图的颜色
    ///   - deaColor: DEA 折线图的颜色
    ///   - minBarHeight: 柱状图最小高度，默认 1pt
    public init(shorterPeroid: Int = 12,
                longerPeroid: Int = 26,
                deaPeroid: Int = 9,
                diffColor: UIColor,
                deaColor: UIColor,
                minBarHeight: CGFloat = 1)
    {
        self.shorterPeroid = shorterPeroid
        self.longerPeroid = longerPeroid
        self.deaPeroid = deaPeroid
        self.diffColor = diffColor
        self.deaColor = deaColor
        self.minBarHeight = minBarHeight
    }
}

/// MACD 图表
public class MACDChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = IndicatorQuoteProcessor<Input, MACDIndicator, MACDConfiguration, MACDAlgorithm<Input>>
    public let quoteProcessor: QuoteProcessor?

    private let configuration: MACDConfiguration
    private var upHistogramLayer = ShapeLayer()
    private var downHistogramLayer = ShapeLayer()
    private let diffLayer = LineChartLayer()
    private let deaLayer = LineChartLayer()

    /// 创建 MACD 图表
    /// - Parameter configuration: 配置信息
    public init(configuration: MACDConfiguration) {
        self.configuration = configuration
        self.quoteProcessor = .init(id: configuration,
                                    algorithm: .init(
                                        shorterPeroid: configuration.shorterPeroid,
                                        longerPeroid: configuration.longerPeroid,
                                        deaPeroid: configuration.deaPeroid))
        diffLayer.strokeColor = configuration.diffColor.cgColor
        deaLayer.strokeColor = configuration.deaColor.cgColor
    }

    public func updateZPosition(_ position: CGFloat) {
        upHistogramLayer.zPosition = position
        downHistogramLayer.zPosition = position
        diffLayer.zPosition = position + 0.1
        deaLayer.zPosition = position + 0.2
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(upHistogramLayer)
        view.layer.addSublayer(downHistogramLayer)
        view.layer.addSublayer(diffLayer)
        view.layer.addSublayer(deaLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        guard let values = context.contextValues[configuration] else {
            clear()
            return
        }
        diffLayer.lineWidth = context.configuration.lineWidth
        deaLayer.lineWidth = context.configuration.lineWidth
        diffLayer.update(with: context,
                         indictaorValues: values,
                         keyPath: \.diff,
                         color: configuration.diffColor)
        deaLayer.update(with: context,
                        indictaorValues: values,
                        keyPath: \.dea,
                        color: configuration.deaColor)
        rendererHistogram(context: context, values: values)
    }

    private func clear() {
        upHistogramLayer.clear()
        downHistogramLayer.clear()
        diffLayer.clear()
        deaLayer.clear()
    }

    public func tearDown(in view: ChartView<Input>) {
        upHistogramLayer.removeFromSuperlayer()
        downHistogramLayer.removeFromSuperlayer()
        diffLayer.removeFromSuperlayer()
        deaLayer.removeFromSuperlayer()
    }

    public func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        let value = context.contextValues[configuration]?[quoteIndex]
        let font = context.configuration.captionFont
        let macd = "MACD(\(configuration.shorterPeroid),\(configuration.longerPeroid),\(configuration.deaPeroid))"
        let formatter = context.preferredFormatter
        return [
            captionText(value: value?.diff, title: "DIF", formatter: formatter, color: configuration.diffColor, font: font),
            captionText(value: value?.dea, title: "DEA", formatter: formatter, color: configuration.deaColor, font: font),
            captionText(value: value?.histogram, title: macd, formatter: formatter, color: context.configuration.captionColor, font: font)
        ]
    }

    private func captionText(value: CGFloat?,
                             title: String,
                             formatter: NumberFormatting,
                             color: UIColor,
                             font: UIFont) -> NSAttributedString
    {
        let text = value.flatMap { formatter.format($0) } ?? "--"
        return NSAttributedString(string: "\(title):\(text)",
                                  attributes: [
                                      .foregroundColor: color,
                                      .font: font
                                  ])
    }
}

// MARK: - Renderer Histogram

extension MACDChart {
    private func rendererHistogram(context: Context, values: ReadonlyOffsetArray<MACDIndicator>) {
        let (slice, range) = values.sliceAndRange(for: context.visibleRange)
        let upPath = CGMutablePath()
        let downPath = CGMutablePath()
        defer {
            upHistogramLayer.fillColor = context.configuration.upColor.cgColor
            downHistogramLayer.fillColor = context.configuration.downColor.cgColor
            upHistogramLayer.path = upPath
            downHistogramLayer.path = downPath
        }
        let peak = context.extremePoint.max - context.extremePoint.min
        guard peak > 0 else { return }
        let zeroY = yOffset(for: 0, context: context)
        zip(slice, range).forEach { macd, index in
            guard let macd = macd.histogram else { return }
            if macd >= 0 {
                writePath(into: upPath, macd: macd, context: context, index: index, zeroY: zeroY)
            } else {
                writePath(into: downPath, macd: macd, context: context, index: index, zeroY: zeroY)
            }
        }
    }

    private func writePath(into path: CGMutablePath,
                           macd: CGFloat,
                           context: RendererContext<Input>,
                           index: Int,
                           zeroY: CGFloat)
    {
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        let barX = (barWidth + spacing) * CGFloat(index)
        let barRect = rect(for: macd,
                           x: _pixelCeil(barX),
                           width: barWidth,
                           zeroY: zeroY,
                           context: context)
        path.addRect(barRect)
    }

    private func rect(for macd: CGFloat,
                      x: CGFloat,
                      width: CGFloat,
                      zeroY: CGFloat,
                      context: Context) -> CGRect
    {
        let y = yOffset(for: macd, context: context)
        let (minY, maxY) = y > zeroY ? (zeroY, y) : (y, zeroY)
        let height = max(configuration.minBarHeight, maxY - minY)
        return CGRect(x: x, y: minY, width: width, height: height)
    }

    private func yOffset(for price: CGFloat, context: Context) -> CGFloat {
        let height = context.contentRect.height
        let minY = context.contentRect.minY
        let peak = context.extremePoint.max - context.extremePoint.min
        return height - height * (price - context.extremePoint.min) / peak + minY
    }
}

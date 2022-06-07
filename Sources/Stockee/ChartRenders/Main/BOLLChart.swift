//
//  BOLLChart.swift
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

/// BOLL 参数
public struct BOLLConfiguration: ContextKey {
    public typealias Value = ReadonlyOffsetArray<BOLLIndicator>
    /// 观察周期
    public var period: Int
    /// 较低价格指标的颜色
    public var lowerColor: UIColor
    /// 中间价格指标的颜色
    public var middleColor: UIColor
    /// 较高价格指标的颜色
    public var upperColor: UIColor

    /// 创建 BOLL 配置信息
    /// - Parameters:
    ///   - period: 观察周期
    ///   - lowerColor: 较低价格指标的颜色
    ///   - middleColor: 中间价格指标的颜色
    ///   - upperColor: 较高价格指标的颜色
    public init(period: Int, lowerColor: UIColor, middleColor: UIColor, upperColor: UIColor) {
        self.period = period
        self.lowerColor = lowerColor
        self.middleColor = middleColor
        self.upperColor = upperColor
    }
}

/// BOLL 图表
public class BOLLChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = IndicatorQuoteProcessor<Input, BOLLIndicator, BOLLConfiguration, BollingerBandsAlgorithm<Input>>
    public let quoteProcessor: IndicatorQuoteProcessor<Input, BOLLIndicator, BOLLConfiguration, BollingerBandsAlgorithm<Input>>?
    /// 配置信息
    private let configuration: BOLLConfiguration
    private let lowerLayer = LineChartLayer()
    private let middleLayer = LineChartLayer()
    private let upperLayer = LineChartLayer()

    /// 创建一个 BOLL 图表
    /// - Parameter configuration: 配置信息
    public init(configuration: BOLLConfiguration) {
        self.configuration = configuration
        self.quoteProcessor = .init(id: configuration,
                                    algorithm: .init(period: configuration.period))
    }

    public func updateZPosition(_ position: CGFloat) {
        lowerLayer.zPosition = position
        middleLayer.zPosition = position + 0.1
        upperLayer.zPosition = position + 0.2
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(lowerLayer)
        view.layer.addSublayer(middleLayer)
        view.layer.addSublayer(upperLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        guard let values = context.contextValues[configuration] else {
            clear()
            return
        }
        lowerLayer.update(with: context,
                          indictaorValues: values,
                          keyPath: \.lower,
                          color: configuration.lowerColor)

        middleLayer.update(with: context,
                           indictaorValues: values,
                           keyPath: \.middle,
                           color: configuration.middleColor)

        upperLayer.update(with: context,
                          indictaorValues: values,
                          keyPath: \.upper,
                          color: configuration.upperColor)
    }

    private func clear() {
        upperLayer.clear()
        lowerLayer.clear()
        middleLayer.clear()
    }

    public func tearDown(in view: ChartView<Input>) {
        lowerLayer.removeFromSuperlayer()
        middleLayer.removeFromSuperlayer()
        upperLayer.removeFromSuperlayer()
    }

    public func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        let value = context.contextValues[configuration]?[quoteIndex]
        let font = context.configuration.captionFont
        return [
            captionText(for: \.middle, value: value, title: "MB", formatter: context.preferredFormatter, color: configuration.middleColor, font: font),
            captionText(for: \.lower, value: value, title: "LB", formatter: context.preferredFormatter, color: configuration.lowerColor, font: font),
            captionText(for: \.upper, value: value, title: "UB", formatter: context.preferredFormatter, color: configuration.upperColor, font: font)
        ]
    }

    private func captionText(for keyPath: KeyPath<BOLLIndicator, CGFloat>,
                             value: BOLLIndicator?,
                             title: String,
                             formatter: NumberFormatting?,
                             color: UIColor,
                             font: UIFont) -> NSAttributedString
    {
        let value = value?[keyPath: keyPath]
        let formatter = formatter ?? NumberFormatter()
        let text = value.flatMap { formatter.format($0) } ?? "--"
        return NSAttributedString(string: "\(title):\(text)",
                                  attributes: [
                                      .foregroundColor: color,
                                      .font: font
                                  ])
    }
}

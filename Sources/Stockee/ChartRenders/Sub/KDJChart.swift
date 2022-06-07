//
//  KDJChart.swift
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

/// KDJ 配置信息
public struct KDJConfiguration: ContextKey {
    public typealias Value = ReadonlyOffsetArray<KDJIndicator>
    /// 观察周期
    public var period: Int = 9
    public var kColor: UIColor
    public var dColor: UIColor
    public var jColor: UIColor

    /// 创建一个 KDJ 配置
    /// - Parameters:
    ///   - period: 观察周期，默认为 9，也就是 KDJ(9,3,3)
    ///   - kColor: K 值折线图的颜色
    ///   - dColor: D 值折线图的颜色
    ///   - jColor: J 值折线图的颜色
    public init(period: Int = 9, kColor: UIColor, dColor: UIColor, jColor: UIColor) {
        self.period = period
        self.kColor = kColor
        self.dColor = dColor
        self.jColor = jColor
    }
}

/// KDJ 图表
public class KDJChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = IndicatorQuoteProcessor<Input, KDJIndicator, KDJConfiguration, KDJAlgorithm<Input>>
    public let quoteProcessor: QuoteProcessor?
    private let configuration: KDJConfiguration
    private let kLayer = LineChartLayer()
    private let dLayer = LineChartLayer()
    private let jLayer = LineChartLayer()

    /// 创建 KDJ 图表
    /// - Parameter configuration: 配置信息
    public init(configuration: KDJConfiguration) {
        self.configuration = configuration
        self.quoteProcessor = .init(id: configuration,
                                    algorithm: .init(period: configuration.period))
        kLayer.strokeColor = configuration.kColor.cgColor
        dLayer.strokeColor = configuration.dColor.cgColor
        jLayer.strokeColor = configuration.jColor.cgColor
    }

    public func updateZPosition(_ position: CGFloat) {
        kLayer.zPosition = position
        dLayer.zPosition = position + 0.1
        jLayer.zPosition = position + 0.2
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(kLayer)
        view.layer.addSublayer(dLayer)
        view.layer.addSublayer(jLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        guard let values = context.contextValues[configuration] else {
            clear()
            return
        }
        kLayer.lineWidth = context.configuration.lineWidth
        dLayer.lineWidth = context.configuration.lineWidth
        jLayer.lineWidth = context.configuration.lineWidth
        kLayer.update(with: context,
                      indictaorValues: values,
                      keyPath: \.k,
                      color: configuration.kColor)

        dLayer.update(with: context,
                      indictaorValues: values,
                      keyPath: \.d,
                      color: configuration.dColor)

        jLayer.update(with: context,
                      indictaorValues: values,
                      keyPath: \.j,
                      color: configuration.jColor)
    }

    private func clear() {
        kLayer.clear()
        dLayer.clear()
        jLayer.clear()
    }

    public func tearDown(in view: ChartView<Input>) {
        kLayer.removeFromSuperlayer()
        dLayer.removeFromSuperlayer()
        jLayer.removeFromSuperlayer()
    }

    public func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        let value = context.contextValues[configuration]?[quoteIndex]
        let font = context.configuration.captionFont
        let formatter = context.preferredFormatter
        return [
            captionText(value: value?.k, title: "K", formatter: formatter, color: configuration.kColor, font: font),
            captionText(value: value?.d, title: "D", formatter: formatter, color: configuration.dColor, font: font),
            captionText(value: value?.j, title: "J", formatter: formatter, color: configuration.jColor, font: font)
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

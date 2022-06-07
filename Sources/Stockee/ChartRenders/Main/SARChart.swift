//
//  SARChart.swift
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

/// SAR 配置信息
public struct SARConfiguration: ContextKey {
    public typealias Value = ReadonlyOffsetArray<SARIndicator>
    /// 计算周期
    public var period: Int
    /// 最小加速因子
    public var minAF: CGFloat
    /// 最大加速因子
    public var maxAF: CGFloat
    /// 上升趋势的颜色
    public var upColor: UIColor
    /// 下降趋势的颜色
    public var downColor: UIColor
    /// 反转点的颜色
    public var reversalColor: UIColor
    /// 填充色
    public var fillColor: UIColor

    /// 创建一个 SAR 配置信息
    /// - Parameters:
    ///   - period: 计算 SAR 值的周期，默认为 4
    ///   - minAF: 最小加速因子，默认为：0.02
    ///   - maxAF: 最大加速因子，默认为：0.2
    ///   - upColor: 上升趋势的颜色
    ///   - downColor: 下降趋势的颜色
    ///   - reversalColor: 反转点的颜色
    ///   - fillColor: 填充色，默认白色
    public init(period: Int = 4,
                minAF: CGFloat = 0.02,
                maxAF: CGFloat = 0.2,
                upColor: UIColor,
                downColor: UIColor,
                reversalColor: UIColor,
                fillColor: UIColor = .white)
    {
        self.period = period
        self.minAF = minAF
        self.maxAF = maxAF
        self.upColor = upColor
        self.downColor = downColor
        self.reversalColor = reversalColor
        self.fillColor = fillColor
    }
}

/// SAR 图表
public class SARChart<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = IndicatorQuoteProcessor<Input, SARIndicator, SARConfiguration, SARAlgorithm<Input>>
    public let quoteProcessor: QuoteProcessor?

    private let configuration: SARConfiguration
    /// 绘制上升趋势的 layer
    private let upLayer = ShapeLayer()
    /// 绘制下降趋势的 layer
    private let downLayer = ShapeLayer()
    /// 绘制翻转点的 layer
    private let reversalLayer = ShapeLayer()

    public init(configuration: SARConfiguration) {
        self.configuration = configuration
        self.quoteProcessor = .init(id: configuration,
                                    algorithm: .init(period: configuration.period,
                                                     minAF: configuration.minAF,
                                                     maxAF: configuration.maxAF))
        let lineWidth: CGFloat = 1
        upLayer.lineWidth = lineWidth
        upLayer.fillColor = configuration.fillColor.cgColor
        upLayer.strokeColor = configuration.upColor.cgColor
        downLayer.lineWidth = lineWidth
        downLayer.fillColor = configuration.fillColor.cgColor
        downLayer.strokeColor = configuration.downColor.cgColor
        reversalLayer.lineWidth = lineWidth
        reversalLayer.fillColor = configuration.fillColor.cgColor
        reversalLayer.strokeColor = configuration.reversalColor.cgColor
    }

    public func updateZPosition(_ position: CGFloat) {
        downLayer.zPosition = position
        upLayer.zPosition = position
        reversalLayer.zPosition = position
    }

    public func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(upLayer)
        view.layer.addSublayer(downLayer)
        view.layer.addSublayer(reversalLayer)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        guard let values = context.contextValues[configuration] else {
            clear()
            return
        }
        let (slice, range) = values.sliceAndRange(for: context.visibleRange)
        let upPath = CGMutablePath()
        let downPath = CGMutablePath()
        let reversalPath = CGMutablePath()
        defer {
            upLayer.path = upPath
            downLayer.path = downPath
            reversalLayer.path = reversalPath
        }
        let peak = context.extremePoint.max - context.extremePoint.min
        guard peak > 0 else { return }
        zip(slice, range).forEach { sar, index in
            let x = xOffset(at: index, in: context)
            let y = yOffset(for: sar.sar, peak: peak, context: context)
            let rect = CGRect(origin: .init(x: x, y: y), size: .zero).insetBy(dx: -1.5, dy: -1.5)
            if sar.isReversal {
                reversalPath.addEllipse(in: rect)
            } else if sar.isUp {
                upPath.addEllipse(in: rect)
            } else {
                downPath.addEllipse(in: rect)
            }
        }
    }

    private func clear() {
        upLayer.clear()
        downLayer.clear()
        reversalLayer.clear()
    }

    public func tearDown(in view: ChartView<Input>) {
        upLayer.removeFromSuperlayer()
        downLayer.removeFromSuperlayer()
        reversalLayer.removeFromSuperlayer()
    }

    public func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        let value = context.contextValues[configuration]?[quoteIndex]
        let font = context.configuration.captionFont
        let text = value.flatMap {
            context.preferredFormatter.format($0.sar)
        } ?? "--"
        return [
            NSAttributedString(string: "SAR:\(text)",
                               attributes: [
                                   .font: font,
                                   .foregroundColor: configuration.upColor
                               ])
        ]
    }

    private func yOffset(for value: CGFloat, peak: CGFloat, context: Context) -> CGFloat {
        let height = context.contentRect.height
        let minY = context.contentRect.minY
        return height - height * (value - context.extremePoint.min) / peak + minY
    }

    private func xOffset(at index: Int, in context: Context) -> CGFloat {
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        return (barWidth + spacing) * CGFloat(index) + barWidth / 2
    }
}

//
//  YAxisAnnotation.swift
//  Stockee
//
//  Created by octree on 2022/3/24.
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

/// 用于绘制图表 Group 的 Y 轴
public class YAxisAnnotation<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var formatter: NumberFormatting?
    ///  当前在屏幕上渲染的 Labels
    private var visibleLabels: [UILabel] = []
    /// 重用队列
    private var reusableLabels: [UILabel] = []
    /// zPosition
    private var zPosition: CGFloat = 0 {
        didSet {
            visibleLabels.forEach { $0.layer.zPosition = zPosition }
        }
    }

    private var maxWidth: CGFloat

    /// 创建 Y 轴标注
    /// - Parameters:
    ///   - formatter: Formatter
    ///   - maxWidth: 最大宽度，默认 80
    public init(formatter: NumberFormatting? = nil,
                maxWidth: CGFloat = 80)
    {
        self.formatter = formatter
        self.maxWidth = maxWidth
    }

    public func updateZPosition(_ position: CGFloat) {
        zPosition = position
    }

    public func setup(in _: ChartView<Input>) {}

    public func render(in view: ChartView<Input>, context: Context) {
        let (low, high) = context.extremePoint
        let baseY = context.contentRect.maxY
        let unit = (high - low) / context.contentRect.height
        guard !unit.isNaN, unit != 0 else { return }
        let width = view.frame.width
        let maxX = view.contentOffset.x + width
        let height = context.groupContentRect.height
        let minY = context.groupContentRect.minY
        let count = context.layout.verticalGridCount(heigt: height)
        let interval = height / CGFloat(count)
        let ys = (0 ... count).map { minY + interval * CGFloat($0) }
        setupLabels(count: ys.count, configuration: context.configuration, in: view)
        let formatter = formatter ?? context.preferredFormatter
        zip(visibleLabels, ys).forEach { label, y in
            label.text = formatter.format(low + (baseY - y) * unit)
            label.sizeToFit()
            label.frame.size.width = min(maxWidth, label.frame.width)
            label.frame.origin.y = y
            label.frame.origin.x = maxX - label.frame.width
        }
        if let last = visibleLabels.last {
            last.frame.origin.y = min(last.frame.minY,
                                      context.groupContentRect.maxY - last.frame.height)
        }
    }

    public func tearDown(in _: ChartView<Input>) {
        visibleLabels.forEach { $0.removeFromSuperview() }
    }

    public func extremePoint(contextValues _: ContextValues, visibleRange _: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

// MARK: - Reuse Caption

extension YAxisAnnotation {
    private func setupLabels(count: Int, configuration: Configuration, in view: UIView) {
        if visibleLabels.count > count {
            for _ in count ..< visibleLabels.count {
                enqueueReusableLabel(visibleLabels.removeLast())
            }
        } else {
            for _ in visibleLabels.count ..< count {
                dequeueReusableLabel(configuration: configuration, in: view)
            }
        }
    }

    /// 把 View 放入重用队列
    private func enqueueReusableLabel(_ view: UILabel) {
        view.removeFromSuperview()
        reusableLabels.append(view)
    }

    /// 从队列中重用或者创建一个新的
    @discardableResult
    private func dequeueReusableLabel(configuration: Configuration, in view: UIView) -> UILabel {
        let label: UILabel
        if reusableLabels.count > 0 {
            label = reusableLabels.removeLast()
        } else {
            label = .init()
        }
        label.textColor = configuration.style.captionColor
        label.font = configuration.captionFont
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 1
        label.layer.zPosition = zPosition
        visibleLabels.append(label)
        view.addSubview(label)
        return label
    }
}

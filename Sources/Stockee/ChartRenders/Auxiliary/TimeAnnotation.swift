//
//  TimeIndicator.swift
//  Stockee
//
//  Created by octree on 2022/3/22.
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

/// 用来展示 X 轴日期
public class TimeAnnotation<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    private var formatter: DateFormatter
    private var visibleLabels: [UILabel] = []
    private var reusableLabels: [UILabel] = []
    private var zPosition: CGFloat = 0 {
        didSet {
            visibleLabels.forEach { $0.layer.zPosition = zPosition }
        }
    }

    /// 创建 X 轴日期的图表
    /// - Parameter dateFormat: 日期格式
    public init(dateFormat: String) {
        formatter = DateFormatter()
        formatter.dateFormat = dateFormat
    }

    public func updateZPosition(_ position: CGFloat) {
        zPosition = position
    }

    public func setup(in view: ChartView<Input>) {}

    public func render(in view: ChartView<Input>, context: Context) {
        let width = view.frame.width
        var x = view.contentOffset.x
        let count = context.layout.horizontalGridCount(width: width)
        let interval = width / CGFloat(count)
        let xs = (0 ... count).map { x + interval * CGFloat($0) }
        let indices = xs.compactMap { x -> Int? in
            if x < 0, context.data.count > 0 { return 0 }
            return context.layout.quoteIndex(at: .init(x: x, y: 0))
        }
        setupLabels(count: indices.count, configuration: context.configuration, in: view)
        let midY = context.contentRect.midY
        zip(visibleLabels, indices).forEach { label, index in
            label.text = formatter.string(from: context.data[index].date)
            label.sizeToFit()
            if index == indices.first {
                label.center = .init(x: x + label.frame.width / 2, y: midY)
            } else if index == indices.last {
                label.center = .init(x: x - label.frame.width / 2, y: midY)
            } else {
                label.center = .init(x: x, y: midY)
            }
            x += interval
        }
    }

    public func tearDown(in view: ChartView<Input>) {
        visibleLabels.forEach { $0.removeFromSuperview() }
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

// MARK: - Reuse Caption

extension TimeAnnotation {
    private func setupLabels(count: Int, configuration: Configuration, in view: UIView) {
        if visibleLabels.count > count {
            for _ in count..<visibleLabels.count {
                enqueueReusableLabel(visibleLabels.removeLast())
            }
        } else {
            for _ in visibleLabels.count..<count {
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
        label.layer.zPosition = zPosition
        visibleLabels.append(label)
        view.addSubview(label)
        return label
    }
}

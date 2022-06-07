//
//  SelectedTimeIndicator.swift
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

/// 用于显示选择的 Quote 的日期
public class SelectedTimeIndicator<Input: Quote>: ChartRenderer {
    public typealias Input = Input
    public typealias QuoteProcessor = NopeQuoteProcessor<Input>
    /// 背景颜色
    public var backgroundColor: UIColor {
        didSet {
            label.backgroundColor = backgroundColor
        }
    }

    /// 文字颜色
    public var textColor: UIColor {
        didSet {
            label.textColor = textColor
        }
    }

    /// 日期格式，默认为：yyyy-MM-dd HH:mm
    public var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    /// 水平 Padding，｜PaddingH｜Text｜PaddingH｜
    public var paddingH: CGFloat = 2

    private let label = UILabel()

    public init(backgroundColor: UIColor = .black, textColor: UIColor = .white) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        label.textAlignment = .center
        label.backgroundColor = backgroundColor
        label.textColor = textColor
        label.isHidden = true
    }

    public func updateZPosition(_ position: CGFloat) {
        label.layer.zPosition = .greatestFiniteMagnitude
    }

    public func setup(in view: ChartView<Input>) {
        view.addSubview(label)
    }

    public func render(in view: ChartView<Input>, context: Context) {
        defer { label.isHidden = context.selectedIndex == nil }
        guard let selectedIndex = context.selectedIndex else {
            return
        }
        label.font = context.configuration.captionFont
        let midX = context.layout.quoteMidX(at: selectedIndex)
        let date = context.data[selectedIndex].date
        label.text = formatter.string(from: date)
        label.sizeToFit()
        var frame = label.frame
        let width = frame.width + paddingH * 2
        let minX = view.contentOffset.x
        let maxX = minX + view.frame.width - width
        let x = min(maxX, max(minX, midX - width / 2))
        frame.origin = .init(x: x, y: context.contentRect.minY)
        frame.size.width = width
        frame.size.height = context.contentRect.height
        label.frame = frame
    }

    public func tearDown(in view: ChartView<Input>) {
        label.removeFromSuperview()
    }

    public func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        nil
    }
}

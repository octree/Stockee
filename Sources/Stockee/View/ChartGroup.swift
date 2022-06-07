//
//  ChartGroup.swift
//  Stockee
//
//  Created by octree on 2022/3/18.
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

/// 一组 Chart 的集合，例如，主图可以是一个 Group
/// ```
/// ┌──────────────────────────────────┐ ─┬─
/// │  Caption                         │  │
/// ├──────────────────────────────────┤  │
/// │  PaddingTop                      │  │
/// ├──────────────────────────────────┤  │
/// │                                  │  │
/// │                                  │  │
/// │  Charts Renderer Area            │ height
/// │                                  │  │
/// │                                  │  │
/// ├──────────────────────────────────┤  │
/// │  PaddingBottom                   │  │
/// └──────────────────────────────────┘ ─┴─
/// ```
public struct ChartGroup<Input: Quote> {
    public var height: CGFloat
    public var chartPadding: (top: CGFloat, bottom: CGFloat)
    public var charts: [AnyChartRenderer<Input>]
    public var preferredFormatter: NumberFormatting
    public typealias Builder = ChartRendererBuilder<Input>

    /// 创建一个 ChartGroup
    /// - Parameters:
    ///   - height: Group 的高度
    ///   - preferredFormatter: 当前分组的指标值的格式化程序
    ///   - chartPadding: 当前图表渲染的 Padding，不包含 caption
    ///   - charts: 一组 ``ChartRenderer``
    public init(height: CGFloat,
                preferredFormatter: NumberFormatting = NumberFormatter(),
                chartPadding: (top: CGFloat, bottom: CGFloat) = (0, 0),
                @Builder charts: () -> [AnyChartRenderer<Input>]) {
        self.height = height
        self.preferredFormatter = preferredFormatter
        self.chartPadding = chartPadding
        self.charts = charts()
    }
}

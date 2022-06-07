//
//  RendererContext.swift
//  Stockee
//
//  Created by Octree on 2022/3/17.
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

/// 提供给渲染器的上下文信息
public struct RendererContext<Input: Quote> {
    /// 行情信息
    public var data: [Input]
    /// 配置信息
    public var configuration: Configuration
    /// 布局信息
    public var layout: QuoteLayout<Input>
    /// 需要渲染的图表在 ChartView 中的区域
    public var contentRect: CGRect
    /// 当前 Group 在 ChartView 中的区域，包含 Caption
    public var groupContentRect: CGRect
    /// 需要渲染数据的区间
    public var visibleRange: Range<Int>
    /// 其他的上下文信息，例如：计算之后的各种指标信息就会放在这里
    public var contextValues: ContextValues
    /// 极值 cache
    internal var extremePointCache: [(min: CGFloat, max: CGFloat)?] = []
    /// 极值
    public var extremePoint: (min: CGFloat, max: CGFloat) = (0, 1)
    /// 当前 Group 中，标注的高度
    public var captionHeight: CGFloat = .zero
    /// 当前选择的 Quote 的下标
    public var selectedIndex: Int?
    /// 当前触摸显示的点
    public var indicatorPosition: CGPoint?
    /// 当前 ChartGroup 的 formatter
    public var preferredFormatter: NumberFormatting = NumberFormatter()
}

public extension RendererContext {
    subscript<Key: ContextKey>(_ type: Key.Type) -> Key.Value? {
        contextValues[type]
    }
}

extension RendererContext {
    /// 获取某个 Y 坐标的值在图表中 y 的偏移量
    /// - Parameter value: Y 值
    /// - Returns: 偏移量
    func yOffset(for value: CGFloat) -> CGFloat {
        let height = contentRect.height
        let minY = contentRect.minY
        let peak = extremePoint.max - extremePoint.min
        return height - height * (value - extremePoint.min) / peak + minY
    }

    func value(forY y: CGFloat) -> CGFloat {
        let peak = extremePoint.max - extremePoint.min
        let height = contentRect.height
        let maxY = contentRect.maxY
        return (maxY - y) * peak / height + extremePoint.min
    }
}

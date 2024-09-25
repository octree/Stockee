//
//  ChartRenderer.swift
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

/// 图标渲染器
/// 该类型只能是一个 class，CharView 会根据引用地址进行 diff，
/// 从而决定要增加加载、卸载哪些图表
@MainActor
public protocol ChartRenderer: AnyObject {
    associatedtype Input
    associatedtype QuoteProcessor: QuoteProcessing where QuoteProcessor.Input == Input

    typealias Context = RendererContext<Input>
    /// 数据处理器
    var quoteProcessor: QuoteProcessor? { get }
    /// 要显示到上方的标注
    func captions(quoteIndex: Int, context: Context) -> [NSAttributedString]
    /// 加载到 ChartView 的时候，会渲染一次
    func setup(in view: ChartView<Input>)
    /// 更新图标的 zPosition，position 一般为当前 renderer 在 chart 中的下标，所以，你可以在
    /// position..<(position + 1) 之间取无限多个 position，也就意味着你可以增加无数个 Layer
    func updateZPosition(_ position: CGFloat)
    /// 当时图滚动或者数据发生变化时，会调用该方法进行绘制
    func render(in view: ChartView<Input>, context: Context)
    /// 从 ChartView 卸载的时候，会调用一次
    func tearDown(in view: ChartView<Input>)

    /// 获取当前数据的极值
    /// - Parameters:
    ///   - contextValues: Context Values
    ///   - visibleRange: 区间
    /// - Returns: 极值
    func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)?
}

public extension ChartRenderer {
    var quoteProcessor: QuoteProcessor? { nil }
    func captions(quoteIndex: Int, context: Context) -> [NSAttributedString] {
        []
    }
}

@MainActor
public struct AnyChartRenderer<Input: Quote> {
    var processor: AnyQuoteProcessor<Input>?
    var _setup: (ChartView<Input>) -> Void
    var _render: (ChartView<Input>, RendererContext<Input>) -> Void
    var _tearDown: (ChartView<Input>) -> Void
    var _extremePoint: (ContextValues, Range<Int>) -> (min: CGFloat, max: CGFloat)?
    var _updateZPosition: (CGFloat) -> Void
    var _captions: (Int, RendererContext<Input>) -> [NSAttributedString]
    var base: AnyObject

    public init<R: ChartRenderer>(_ renderer: R) where R.Input == Input {
        processor = renderer.quoteProcessor?.typedErased
        _setup = { renderer.setup(in: $0) }
        _render = { renderer.render(in: $0, context: $1) }
        _tearDown = { renderer.tearDown(in: $0) }
        _extremePoint = { renderer.extremePoint(contextValues: $0, visibleRange: $1) }
        _updateZPosition = { renderer.updateZPosition($0) }
        _captions = { renderer.captions(quoteIndex: $0, context: $1) }
        base = renderer
    }

    func setup(in view: ChartView<Input>) {
        _setup(view)
    }

    func render(in view: ChartView<Input>, context: RendererContext<Input>) {
        _render(view, context)
    }

    func tearDown(in view: ChartView<Input>) {
        _tearDown(view)
    }

    func updateZPosition(_ position: CGFloat) {
        _updateZPosition(position)
    }

    func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        _extremePoint(contextValues, visibleRange)
    }

    func captions(quoteIndex: Int, context: RendererContext<Input>) -> [NSAttributedString] {
        _captions(quoteIndex, context)
    }
}

extension AnyChartRenderer: @preconcurrency Equatable {
    public static func == (lhs: AnyChartRenderer<Input>, rhs: AnyChartRenderer<Input>) -> Bool {
        lhs.base === rhs.base
    }
}

extension AnyChartRenderer: @preconcurrency Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}

public extension ChartRenderer where QuoteProcessor.Output: ExtremePointRetrievableCollection {
    func extremePoint(contextValues: ContextValues, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        guard let id = quoteProcessor?.absoluteID,
              let value = contextValues[id] as? QuoteProcessor.Key.Value
        else {
            return nil
        }
        return value.extremePoint(in: visibleRange)
    }
}

//
//  LineChartLayer.swift
//  Stockee
//
//  Created by octree on 2022/3/19.
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

public final class LineChartLayer: ShapeLayer {
    override public init() {
        super.init()
        setup()
    }

    override public init(layer: Any) {
        guard let layer = layer as? LineChartLayer else {
            fatalError("init(layer:) error: layer: \(layer)")
        }
        super.init()
        setup()
        path = layer.path
        strokeColor = layer.strokeColor
        lineWidth = layer.lineWidth
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        fillColor = UIColor.clear.cgColor
    }

    public func updateWithPoints(points: [CGPoint]) {
        path = .lineSegments(with: points)
    }
}

extension LineChartLayer {
    func update<Input: Quote>(with context: RendererContext<Input>,
                              indicatorValues: ReadonlyOffsetArray<CGFloat>,
                              color: UIColor) {
        update(with: context,
               indicatorValues: indicatorValues,
               keyPath: \.self,
               color: color)
    }

    private func drawingPoint<Input: Quote>(at index: Int,
                                            value: CGFloat,
                                            peak: CGFloat,
                                            context: RendererContext<Input>) -> CGPoint {
        let barWidth = context.configuration.barWidth
        let spacing = context.configuration.spacing
        let x = (barWidth + spacing) * CGFloat(index) + barWidth / 2
        return CGPoint(x: x, y: yPosition(for: value, peak: peak, in: context))
    }

    private func yPosition<Input: Quote>(for value: CGFloat,
                                         peak: CGFloat,
                                         in context: RendererContext<Input>) -> CGFloat {
        let height = context.contentRect.height
        let minY = context.contentRect.minY
        return height - height * (value - context.extremePoint.min) / peak + minY
    }
}

extension LineChartLayer {
    func update<Input: Quote, V>(with context: RendererContext<Input>,
                                 indicatorValues: ReadonlyOffsetArray<V>,
                                 keyPath: KeyPath<V, CGFloat>,
                                 color: UIColor) {
        var points: [CGPoint] = []
        defer { updateWithPoints(points: points) }
        let (minValue, maxValue) = context.extremePoint
        let peak = maxValue - minValue
        guard peak > 0 else { return }
        let start = max(0, context.visibleRange.startIndex - 1)
        let end = min(context.data.count, context.visibleRange.endIndex + 1)
        let (slice, range) = indicatorValues.sliceAndRange(for: start ..< end)
        guard !slice.isEmpty else { return }
        points = zip(slice, range).map {
            drawingPoint(at: $0.1, value: $0.0[keyPath: keyPath], peak: peak, context: context)
        }
        strokeColor = color.cgColor
        lineWidth = context.configuration.lineWidth
    }
}

extension LineChartLayer {
    func update<Input: Quote, V>(with context: RendererContext<Input>,
                                 indicatorValues: ReadonlyOffsetArray<V>,
                                 keyPath: KeyPath<V, CGFloat?>,
                                 color: UIColor) {
        var points: [CGPoint] = []
        defer { updateWithPoints(points: points) }
        let (minValue, maxValue) = context.extremePoint
        let peak = maxValue - minValue
        guard peak > 0 else { return }
        let start = max(0, context.visibleRange.startIndex - 1)
        let end = min(context.data.count, context.visibleRange.endIndex + 1)
        var (slice, range) = indicatorValues.sliceAndRange(for: start ..< end)
        let index = slice.firstIndex { $0[keyPath: keyPath] != nil } ?? slice.endIndex
        let skipCount = index - slice.startIndex
        slice = slice.dropFirst(skipCount)
        range = range.dropFirst(skipCount)
        guard !slice.isEmpty else { return }
        points = zip(slice, range).map {
            drawingPoint(at: $0.1, value: $0.0[keyPath: keyPath]!, peak: peak, context: context)
        }
        strokeColor = color.cgColor
        lineWidth = context.configuration.lineWidth
    }
}

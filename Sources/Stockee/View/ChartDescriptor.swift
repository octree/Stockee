//
//  ChartDescriptor.swift
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

import CoreGraphics
import Foundation

/// 用于描述如何渲染一组图表的 Model
public struct ChartDescriptor<Input: Quote> {
    public let spacing: CGFloat
    public let groups: [ChartGroup<Input>]
    private var cache: [(y: CGFloat, height: CGFloat)] = []
    public typealias Builder = ChartGroupBuilder<Input>

    /// 创建一个 ChartDescriptor
    /// - Parameters:
    ///   - spacing: ``ChartGroup``之间的间隔，默认为 0
    ///   - groups: 一组 ``ChartGroup``
    public init(spacing: CGFloat = 0, @Builder groups: () -> [ChartGroup<Input>]) {
        self.spacing = spacing
        self.groups = groups()
        cacheLayoutInfo()
    }

    init() {
        spacing = 0
        groups = []
    }

    private mutating func cacheLayoutInfo() {
        guard groups.count > 0 else { return }
        var y: CGFloat = 0
        for group in groups {
            cache.append((y, group.height))
            y += spacing + group.height
        }
    }

    func groupIndex(contains point: CGPoint) -> Int? {
        for (index, (y, height)) in cache.enumerated() where point.y >= y && point.y <= y + height {
            return index
        }
        return nil
    }
}

extension ChartDescriptor {
    var contentHeight: CGFloat {
        guard groups.count > 0 else { return 0 }
        return cache.last!.y + cache.last!.height
    }

    func layoutInfoForGroup(at index: Int) -> (y: CGFloat, height: CGFloat) {
        cache[index]
    }

    var renderers: [AnyChartRenderer<Input>] {
        groups.flatMap { $0.charts }
    }

    var rendererSet: Set<AnyChartRenderer<Input>> {
        Set(renderers)
    }
}

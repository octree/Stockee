//
//  Configuration.swift
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

public struct Style {
    /// 一些小注释的颜色
    public var captionColor: UIColor = .gray
    /// 上升趋势的颜色
    public var upColor: UIColor = .red
    /// 下降趋势的颜色
    public var downColor: UIColor = .green
    /// 选择状态下，十字线的颜色
    public var selectionIndicatorLineColor: UIColor = .lightGray
    /// 选择状态下，十字线交点的颜色
    public var selectionIndicatorPointColor: UIColor = .orange

    public init() {}
}

/// 配置信息
@dynamicMemberLookup
public struct Configuration {
    /// 每个报价在图表中的宽度，默认 6
    public var barWidth: CGFloat = 6
    /// 报价之间的间隔，默认 1
    public var spacing: CGFloat = 2
    /// 影线宽度，默认 1
    public var shadowLineWidth: CGFloat = 1
    /// 折线图的宽度，默认 1
    public var lineWidth: CGFloat = 1
    /// 默认为 9
    public var captionFont: UIFont = .systemFont(ofSize: 9, weight: .light)
    /// 标注说明文字的 padding
    public var captionPadding: UIEdgeInsets
    /// 标注说明文字的横向间距和行间距
    public var captionSpacing: (h: CGFloat, v: CGFloat)
    /// 网格的最小间距
    public var gridInterval: (h: CGFloat, v: CGFloat)
    /// 颜色样式
    public var style: Style = .init()

    public init(barWidth: CGFloat = 6,
                spacing: CGFloat = 1,
                shadowLineWidth: CGFloat = 1,
                lineWidth: CGFloat = 1,
                captionFont: UIFont = .systemFont(ofSize: 8),
                captionPadding: UIEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8),
                captionSpacing: (h: CGFloat, v: CGFloat) = (4, 2),
                gridInterval: (h: CGFloat, v: CGFloat) = (120, 50),
                style: Style = .init())
    {
        self.barWidth = barWidth
        self.spacing = spacing
        self.shadowLineWidth = shadowLineWidth
        self.lineWidth = lineWidth
        self.captionFont = captionFont
        self.captionPadding = captionPadding
        self.captionSpacing = captionSpacing
        self.gridInterval = gridInterval
        self.style = style
    }
}

public extension Configuration {
    subscript<V>(dynamicMember keyPath: WritableKeyPath<Style, V>) -> V {
        _read {
            yield style[keyPath: keyPath]
        }
        _modify {
            yield &style[keyPath: keyPath]
        }
    }

    subscript<V>(dynamicMember keyPath: KeyPath<Style, V>) -> V {
        style[keyPath: keyPath]
    }
}

extension Configuration {
    func scaled(_ scale: CGFloat) -> Configuration {
        .init(barWidth: barWidth * scale,
              spacing: spacing,
              shadowLineWidth: shadowLineWidth,
              lineWidth: lineWidth,
              captionFont: captionFont,
              captionPadding: captionPadding,
              captionSpacing: captionSpacing,
              gridInterval: gridInterval,
              style: style)
    }
}

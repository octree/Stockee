//
//  IndicatorLabel.swift
//  Stockee
//
//  Created by octree on 2022/4/8.
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

public class IndicatorLabel: UIView {
    public enum Direction {
        case left
        case right
    }

    public var triangleWidth: CGFloat = 6 {
        didSet {
            updateLayer()
            updateLabelFrame()
            invalidateIntrinsicContentSize()
        }
    }

    public let shapeLayer: ShapeLayer = .init()
    public var triangleDirection: Direction = .left {
        didSet {
            label.textAlignment = triangleDirection == .left ? .left : .right
            updateLayer()
            updateLabelFrame()
        }
    }

    override public var frame: CGRect {
        didSet {
            updateLayer()
            updateLabelFrame()
        }
    }

    public let label: UILabel = .init()
    private var left: NSLayoutConstraint!
    private var right: NSLayoutConstraint!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureHierarchy()
    }

    private func configureHierarchy() {
        layer.addSublayer(shapeLayer)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        addSubview(label)
    }

    private func updateLayer() {
        let path = CGMutablePath()
        if triangleDirection == .left {
            path.move(to: CGPoint(x: 0, y: bounds.midY))
            path.addLine(to: CGPoint(x: triangleWidth, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            path.addLine(to: CGPoint(x: triangleWidth, y: bounds.height))
        } else {
            path.move(to: CGPoint(x: bounds.width, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.width - triangleWidth, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.width - triangleWidth, y: bounds.height))
        }
        path.closeSubpath()
        shapeLayer.path = path
    }

    private func updateLabelFrame() {
        var frame = bounds
        frame.size.width -= triangleWidth
        if triangleDirection == .left {
            frame.origin.x += triangleWidth
        }
        label.frame = frame
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        if size.width != .greatestFiniteMagnitude {
            size.width -= triangleWidth
        }
        var expected = label.sizeThatFits(size)
        expected.width += triangleWidth
        return expected
    }
}

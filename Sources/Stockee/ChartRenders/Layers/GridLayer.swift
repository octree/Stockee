//
//  GridLayer.swift
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

final class GridLayer: ShapeLayer {
    override public init() {
        super.init()
        setup()
    }

    override public init(layer: Any) {
        super.init()
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        fillColor = UIColor.clear.cgColor
    }
}

extension GridLayer {
    @MainActor
    func draw<T: Quote>(in context: RendererContext<T>) {
        let width = context.layout.view.frame.width
        let height = context.groupContentRect.height

        let minX = context.layout.view.contentOffset.x
        let minY = context.groupContentRect.minY
        let maxY = context.groupContentRect.maxY
        let maxX = width + minX
        let path = CGMutablePath()
        let vcount = context.layout.verticalGridCount(heigt: height)
        let vInterval = height / CGFloat(vcount)
        var y = minY
        (0 ... vcount).forEach { _ in
            path.addHLine(minX: minX, maxX: maxX, y: y)
            y += vInterval
        }

        let hcount = context.layout.horizontalGridCount(width: width)
        let hInterval = width / CGFloat(hcount)
        var x = minX
        (1 ..< hcount).forEach { _ in
            x += hInterval
            path.addVLine(minY: minY, maxY: maxY, x: x)
        }
        self.path = path
    }
}

extension CGMutablePath {
    func addHLine(minX: CGFloat, maxX: CGFloat, y: CGFloat) {
        move(to: .init(x: minX, y: y))
        addLine(to: .init(x: maxX, y: y))
    }

    func addVLine(minY: CGFloat, maxY: CGFloat, x: CGFloat) {
        move(to: .init(x: x, y: minY))
        addLine(to: .init(x: x, y: maxY))
    }
}

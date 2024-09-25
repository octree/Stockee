//
//  SelectionIndicatorLayer.swift
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

/// 用户长按选择时的十字线指示器
@MainActor
class SelectionIndicatorDrawer<Input: Quote> {
    private var lineLayer: ShapeLayer = .init()
    private var pointLayer: ShapeLayer = .init()
    var zPosition: CGFloat = 0 {
        didSet {
            lineLayer.zPosition = zPosition
            pointLayer.zPosition = zPosition + 0.1
        }
    }

    var isHidden: Bool = false {
        didSet {
            lineLayer.isHidden = isHidden
            pointLayer.isHidden = isHidden
        }
    }

    init() {
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 1 / UIScreen.main.scale
        pointLayer.lineWidth = 4
    }

    func setup(in view: ChartView<Input>) {
        view.layer.addSublayer(lineLayer)
        view.layer.addSublayer(pointLayer)
    }

    func draw(in view: ChartView<Input>,
              position: CGPoint,
              style: Style,
              showHorizontal: Bool) {
        let x: CGFloat = view.contentOffset.x
        let width = view.frame.width
        let height = view.frame.height
        let linePath = CGMutablePath()
        if showHorizontal {
            linePath.addHLine(minX: x, maxX: x + width, y: position.y)
        }
        linePath.addVLine(minY: 0, maxY: height, x: position.x)
        lineLayer.path = linePath
        lineLayer.strokeColor = style.selectionIndicatorLineColor.cgColor
        pointLayer.isHidden = !showHorizontal
        if showHorizontal {
            let rect = CGRect(origin: position, size: .zero).insetBy(dx: -3, dy: -3)
            pointLayer.path = CGPath(ellipseIn: rect, transform: nil)
            pointLayer.fillColor = style.selectionIndicatorPointColor.cgColor
            pointLayer.strokeColor = style.selectionIndicatorPointColor
                .withAlphaComponent(0.4)
                .cgColor
        }
    }

    func tearDown() {
        lineLayer.removeFromSuperlayer()
        pointLayer.removeFromSuperlayer()
    }
}

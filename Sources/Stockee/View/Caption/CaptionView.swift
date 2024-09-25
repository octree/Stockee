//
//  CaptionView.swift
//  Stockee
//
//  Created by octree on 2022/3/21.
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

/// 用于渲染表格标注的 View
final class CaptionView: UIView {
    private var visibleLabels: [UILabel] = []
    private var reusableLabels: [UILabel] = []
    var padding: UIEdgeInsets = .zero {
        didSet {
            isDirty = true
            setNeedsLayout()
        }
    }

    var horizontalSpacing: CGFloat = 0 {
        didSet {
            isDirty = true
            setNeedsLayout()
        }
    }

    var verticalSpacing: CGFloat = 0 {
        didSet {
            isDirty = true
            setNeedsLayout()
        }
    }

    override var frame: CGRect {
        didSet {
            if _pixelCeil(oldValue.width) != _pixelCeil(frame.width) {
                isDirty = true
                setNeedsLayout()
            }
        }
    }

    var width: CGFloat = 0
    private var isDirty: Bool = false
    var attributedTexts: [NSAttributedString] = [] {
        didSet {
            reloadData()
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = _pixelCeil(frame.width)
        defer {
            self.width = width
            self.isDirty = false
        }
        if isDirty {
            layoutItems()
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutItems(fit: size)
    }

    private func reloadData() {
        setupLabels(count: attributedTexts.count)
        zip(visibleLabels, attributedTexts).forEach {
            $0.0.attributedText = $0.1
        }
    }

    @discardableResult
    private func layoutItems(fit size: CGSize? = nil) -> CGSize {
        guard visibleLabels.count > 0 else { return .zero }
        let size = size ?? bounds.size
        let x = padding.left
        var y = padding.top
        let width = size.width - padding.left - padding.right
        let height = size.height - padding.top - padding.bottom
        let spacingH = horizontalSpacing
        let spacingV = verticalSpacing
        func createLayoutContext() -> HorizontalLayoutContext {
            HorizontalLayoutContext(origin: CGPoint(x: x, y: y),
                                    availableSize: CGSize(width: width, height: height),
                                    spacing: spacingH)
        }
        var layout = createLayoutContext()
        for elt in visibleLabels {
            if layout.attemptToLayout(elt) {
                continue
            } else {
                layout.apply()
                y += layout.height + spacingV
                layout = createLayoutContext()
                layout.attemptToLayout(elt)
            }
        }
        layout.apply()
        return CGSize(width: size.width, height: y + layout.height + padding.bottom)
    }
}

// MARK: - Reuse labels

extension CaptionView {
    private func setupLabels(count: Int) {
        if visibleLabels.count > count {
            for _ in count ..< visibleLabels.count {
                enqueueReusableLabel(visibleLabels.removeLast())
            }
        } else {
            for _ in visibleLabels.count ..< count {
                dequeueReusableLabel()
            }
        }
    }

    /// 把 Label 放入重用队列
    private func enqueueReusableLabel(_ label: UILabel) {
        label.removeFromSuperview()
        reusableLabels.append(label)
    }

    /// 从队列中重用或者创建一个新的
    @discardableResult
    private func dequeueReusableLabel() -> UILabel {
        let label: UILabel
        if reusableLabels.count > 0 {
            label = reusableLabels.removeLast()
        } else {
            label = .init()
        }
        addSubview(label)
        visibleLabels.append(label)
        return label
    }
}

@MainActor
struct HorizontalLayoutContext {
    var origin: CGPoint
    var availableSize: CGSize
    var spacing: CGFloat
    private(set) var height: CGFloat = 0
    private var usedWidth: CGFloat = 0
    private var alignedItems = [(UILabel, CGRect)]()

    init(origin: CGPoint,
         availableSize: CGSize,
         spacing: CGFloat) {
        self.origin = origin
        self.availableSize = availableSize
        self.spacing = spacing
    }

    @discardableResult
    mutating func attemptToLayout(_ label: UILabel) -> Bool {
        let itemSize = label.sizeThatFits(availableSize)
        guard alignedItems.isEmpty || availableSize.width - usedWidth >= itemSize.width else {
            return false
        }
        let frame = CGRect(origin: .init(x: origin.x + usedWidth, y: origin.y),
                           size: itemSize)
        alignedItems.append((label, frame))
        usedWidth += itemSize.width + spacing
        height = max(itemSize.height, height)
        return true
    }

    func apply() {
        alignedItems.forEach { $0.0.frame = $0.1 }
    }
}

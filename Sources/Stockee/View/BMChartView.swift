//
//  ChartView.swift
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

import Network
import UIKit

struct GroupExtremePointKey: ContextKey {
    public typealias Value = (CGFloat, CGFloat)
    private var key: AnyHashable
    init(_ key: AnyHashable) {
        self.key = key
    }
}

open class StockScrollView: UIScrollView {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            panGestureDidBegin()
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }

    func panGestureDidBegin() {}
}

/// 用于渲染多组图表的容器
open class ChartView<Input: Quote>: StockScrollView {
    public typealias Renderer = AnyChartRenderer<Input>
    public typealias Descriptor = ChartDescriptor<Input>
    public typealias Group = ChartGroup<Input>
    public typealias Context = RendererContext<Input>

    // MARK: - Properties

    open var expectedHeight: CGFloat {
        contentInset.top + contentInset.bottom + descriptor.contentHeight
    }

    override open var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = expectedHeight
        return size
    }

    /// 配置信息
    open var configuration: Configuration = .init() {
        didSet {
            visibleCaptionViews.forEach {
                $0.padding = configuration.captionPadding
                $0.horizontalSpacing = configuration.captionSpacing.h
                $0.verticalSpacing = configuration.captionSpacing.v
            }
            setNeedRedraw()
        }
    }

    /// 图表缩放大小
    open var chartZoomScale: CGFloat = 1.0 {
        didSet {
            updateContentSize()
            setNeedRedraw()
        }
    }

    override open var contentInset: UIEdgeInsets {
        didSet {
            setNeedRedraw()
        }
    }

    open private(set) var data: [Input] = []
    private(set) var contextValue: ContextValues = .init()
    var scaledConfiguration: Configuration {
        configuration.scaled(chartZoomScale)
    }

    public private(set) lazy var layout: QuoteLayout = .init(self)
    /// 包含一组 ChatGroup，用于描述如何组织、渲染多组图表
    open var descriptor: Descriptor = .init() {
        didSet {
            updateDescriptor(from: oldValue, to: descriptor)
            invalidateIntrinsicContentSize()
        }
    }

    /// 当前选择的下标
    open internal(set) var selectedIndex: Int? {
        didSet {
            guard oldValue != selectedIndex else { return }
            setNeedRedraw()
            if selectedIndex != nil {
                if #available(iOS 13.0, *) {
                    UIImpactFeedbackGenerator(style: .light)
                        .impactOccurred(intensity: 0.75)
                } else {
                    UIImpactFeedbackGenerator(style: .light)
                        .impactOccurred()
                }
            }
            onSelect(selectedIndex)
        }
    }

    /// 用户选择的 quote 的下标发生变化的代理
    open var onSelect: Delegate<Int?, Void> = .init()
    /// 将要渲染的 quote 的区间发生的代理
    open var onWillDisplayRange: Delegate<Range<Int>, Void> = .init()
    /// 渲染结束的代理
    open var onDidDisplayRange: Delegate<Range<Int>, Void> = .init()

    private var longPressPosition: CGPoint = .zero {
        didSet {
            longPressedPositionChanged(longPressPosition)
            if longPressPosition != oldValue {
                setNeedRedraw()
            }
        }
    }

    private lazy var selectionIndicatorDrawer: SelectionIndicatorDrawer<Input> = {
        let drawer = SelectionIndicatorDrawer<Input>()
        drawer.setup(in: self)
        return drawer
    }()

    /// 当前正在显示的 caption view
    private var visibleCaptionViews: [CaptionView] = []
    /// 重用队列
    private var reusableCaptionViews: [CaptionView] = []
    /// 缩放时，要固定位置的 Quote 以及其偏移量
    private var zoomPinnedQuote: (index: Int, midX: CGFloat)?
    private var preZoomScale: CGFloat = 1.0

    // MARK: - Life Cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceHorizontal = true
        setupInteractions()
    }

    // MARK: - Public Methods

    /// 当前的渲染设置为无效，会在下一次渲染循环中更新视图
    public func setNeedRedraw() {
        setNeedsLayout()
    }

    // MARK: Data

    /// 重新加载数据
    /// - Parameter data: 数据
    public func reloadData(_ data: [Input]) {
        self.data = data
        _reloadData()
        let offset = CGPoint(x: contentSize.width - bounds.size.width + contentInset.right,
                             y: -contentInset.top)
        setContentOffset(offset, animated: false)
        selectedIndex = nil
        setNeedRedraw()
    }

    /// 添加一条数据
    /// - Parameter quote: ``Quote``
    public func append(_ quote: Input) {
        data.append(quote)
        _reloadData()
        setNeedRedraw()
    }

    /// 替换最后一条数据
    /// - Parameter quote: ``Quote``
    public func replaceLast(_ quote: Input) {
        data.removeLast()
        data.append(quote)
        _reloadData()
        setNeedRedraw()
    }

    /// 在前面当前数据之前添加一组数据
    /// - Parameter data: 要添加的数据
    public func prepend(_ data: [Input]) {
        self.data = data + self.data
        _reloadData()
        contentOffset.x += CGFloat(data.count) * (layout.barWidth + layout.spacing)
        selectedIndex = nil
        setNeedRedraw()
    }

    private func _reloadData() {
        reloadContextValues()
        updateContentSize()
    }

    // MARK: Override

    override open func layoutSubviews() {
        super.layoutSubviews()
        redraw()
    }

    override func panGestureDidBegin() {
        selectedIndex = nil
    }

    // MARK: - Private Methods

    /// 绘制图表
    private func redraw() {
        let visibleRange = layout.visibleRange()
        onWillDisplayRange(visibleRange)
        defer { onDidDisplayRange(visibleRange) }
        var context = RendererContext(data: data,
                                      configuration: scaledConfiguration,
                                      layout: layout,
                                      contentRect: .zero,
                                      groupContentRect: .zero,
                                      visibleRange: visibleRange,
                                      contextValues: contextValue)
        context.selectedIndex = selectedIndex
        context.indicatorPosition = selectedIndex.map {
            .init(x: layout.quoteMidX(at: $0), y: longPressPosition.y)
        }

        var quoteIndex = selectedIndex
        if quoteIndex == nil, !context.visibleRange.isEmpty {
            quoteIndex = context.visibleRange.endIndex - 1
        }

        for (index, group) in descriptor.groups.enumerated() {
            let (y, height) = descriptor.layoutInfoForGroup(at: index)
            context.preferredFormatter = group.preferredFormatter
            let captionFrame = setupCaption(for: group,
                                            at: index,
                                            quoteIndex: quoteIndex,
                                            y: y,
                                            context: context)
            context.captionHeight = captionFrame.height
            var contentRect = layout.contentRectToDraw(visibleRange: visibleRange, y: y, height: height)
            context.groupContentRect = contentRect
            let chartPadding = group.chartPadding
            contentRect.origin.y += captionFrame.height + chartPadding.top
            contentRect.size.height -= captionFrame.height + chartPadding.top + chartPadding.bottom
            context.contentRect = contentRect
            let ep = extremePoint(for: group, visibleRange: visibleRange)
            context.extremePointCache.append(ep)
            contextValue[GroupExtremePointKey(index)] = ep
            context.extremePoint = ep.flatMap {
                // ⚠️ 如果最大值和最小值一样，则扩大区域，之后需要根据更多情况。例如有没有可能都是 0
                $0.max - $0.min == 0 ? ($0.min * 0.5, $0.min * 1.5) : $0
            } ?? (0, 1)
            group.charts.forEach {
                $0.render(in: self, context: context)
            }
        }
        drawPressIndicator(context: context)
    }

    private func drawPressIndicator(context: Context) {
        guard let position = context.indicatorPosition else {
            selectionIndicatorDrawer.isHidden = true
            return
        }
        selectionIndicatorDrawer.isHidden = false
        let showH = descriptor.groupIndex(contains: position).flatMap {
            context.extremePointCache[$0]
        } != nil
        selectionIndicatorDrawer.draw(in: self,
                                      position: position,
                                      style: configuration.style,
                                      showHorizontal: showH)
    }

    // 设置 caption，并返回 caption height
    private func setupCaption(for group: Group,
                              at index: Int,
                              quoteIndex: Int?,
                              y: CGFloat,
                              context: Context) -> CGRect
    {
        let captionView = visibleCaptionViews[index]
        if let quoteIndex = quoteIndex {
            captionView.attributedTexts = group.charts.flatMap {
                $0.captions(quoteIndex: quoteIndex, context: context)
            }
        } else {
            captionView.attributedTexts = []
        }

        captionView.frame = .init(origin: .init(x: contentOffset.x, y: y),
                                  size: .init(width: frame.width, height: 0))
        captionView.sizeToFit()
        return captionView.frame
    }

    private func extremePoint(for group: Group, visibleRange: Range<Int>) -> (min: CGFloat, max: CGFloat)? {
        let values = group.charts.compactMap {
            $0.extremePoint(contextValues: contextValue, visibleRange: visibleRange)
        }
        return values.map { $0.min }.min().map {
            ($0, values.map { $0.max }.max()!)
        }
    }

    private func updateDescriptor(from lhs: Descriptor, to rhs: Descriptor) {
        let renderers = rhs.renderers
        let patches = lhs.rendererSet.patches(to: Set(renderers))
        patches.deletions.forEach {
            $0.tearDown(in: self)
            removeContextValue(for: $0)
        }
        patches.insertions.forEach {
            $0.setup(in: self)
            calculateContextValue(for: $0)
        }

        renderers.enumerated().forEach {
            $0.element.updateZPosition(CGFloat($0.offset))
        }
        selectionIndicatorDrawer.zPosition = CGFloat(renderers.count + 1)
        setupCaptionView(count: rhs.groups.count)
    }

    private func updateContentSize() {
        contentSize = CGSize(width: layout.contentWidth(for: data),
                             height: descriptor.contentHeight)
    }

    // MARK: Data Processor

    private func reloadContextValues() {
        contextValue = .init()
        contextValue[QuoteContextKey<Input>.self] = data
        for render in descriptor.renderers {
            render.processor?.process(data, writeTo: &contextValue)
        }
    }

    private func removeContextValue(for renderer: Renderer) {
        renderer.processor?.clearValues(in: &contextValue)
    }

    private func calculateContextValue(for renderer: Renderer) {
        renderer.processor?.process(data, writeTo: &contextValue)
    }
}

// MARK: - Interactions

extension ChartView {
    /// 配置缩放、长按等交互
    private func setupInteractions() {
        let zoomInteraction = ZoomInteraction { [unowned self] in
            self.handlePinch(gesture: $0)
        }
        addInteraction(zoomInteraction)
        let position = Binding { [unowned self] in
            longPressPosition
        } set: { [unowned self] in
            longPressPosition = $0
        }
        addInteraction(LongPressInteraction(binding: position))
        let tapInteraction = TapInteraction { [unowned self] in
            if selectedIndex != nil {
                selectedIndex = nil
            } else {
                longPressPosition = $0
            }
        }
        addInteraction(tapInteraction)
    }

    private func longPressedPositionChanged(_ position: CGPoint) {
        guard let index = layout.quoteIndex(at: position) else { return }
        selectedIndex = index
    }

    private func handlePinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            preZoomScale = 1.0
            let point = gesture.location(in: self)
            let index = layout.quoteIndex(at: point) ?? layout.visibleRange().last
            zoomPinnedQuote = index.flatMap { ($0, layout.quoteMidX(at: $0) - contentOffset.x) }
            fallthrough
        case .changed:
            guard let (index, midX) = zoomPinnedQuote else { return }
            let scale = gesture.scale / preZoomScale
            chartZoomScale = max(0.3, min(4, chartZoomScale * scale))
            let offsetX = clamp(offset: layout.quoteMidX(at: index) - midX)
            setContentOffset(CGPoint(x: offsetX, y: -contentInset.top), animated: false)
            preZoomScale = gesture.scale
        case .ended,
             .cancelled:
            zoomPinnedQuote = nil
        default:
            break
        }
    }
}

// MARK: - Reuse Caption

extension ChartView {
    private func setupCaptionView(count: Int) {
        if visibleCaptionViews.count > count {
            for _ in count ..< visibleCaptionViews.count {
                enqueueReusableCaptionView(visibleCaptionViews.removeLast())
            }
        } else {
            for _ in visibleCaptionViews.count ..< count {
                dequeueReusableCaptionView()
            }
        }
    }

    /// 把 View 放入重用队列
    private func enqueueReusableCaptionView(_ view: CaptionView) {
        view.removeFromSuperview()
        reusableCaptionViews.append(view)
    }

    /// 从队列中重用或者创建一个新的
    @discardableResult
    private func dequeueReusableCaptionView() -> CaptionView {
        let view: CaptionView
        if reusableCaptionViews.count > 0 {
            view = reusableCaptionViews.removeLast()
        } else {
            view = .init()
        }
        addSubview(view)
        view.padding = configuration.captionPadding
        view.horizontalSpacing = configuration.captionSpacing.h
        view.verticalSpacing = configuration.captionSpacing.v
        visibleCaptionViews.append(view)
        return view
    }
}

extension ChartView {
    var maxContentOffset: CGFloat {
        contentSize.width - bounds.size.width + contentInset.right
    }

    func clamp(offset: CGFloat) -> CGFloat {
        max(-contentInset.left, min(offset, maxContentOffset))
    }
}

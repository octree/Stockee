//
//  ViewController.swift
//  Playground
//
//  Created by Octree on 2022/3/10.
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

import Stockee
import UIKit

public struct Candle: Quote, Codable {
    public var date: Date
    public var start: Int = 0
    public var end: Int = 0
    public var low: CGFloat
    public var high: CGFloat
    public var open: CGFloat
    public var close: CGFloat
    public var volume: CGFloat
}

class ViewController: UIViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    private lazy var chartView: ChartView<Candle> = .init(frame: .zero)
    @IBOutlet var lastStackView: UIStackView!
    private var symbol: String = "BNBUSDT" {
        didSet {
            resetDatasource()
        }
    }

    private var interval: String = "5m" {
        didSet {
            resetDatasource()
        }
    }

    private var isLoading: Bool = false
    // 主图/副图指标
    private var chartOptions: ChartOption = [] {
        didSet {
            configureChartDescriptor()
        }
    }

    // 是否是分时图
    private var isTimeShare: Bool = false {
        didSet {
            configureChartDescriptor()
        }
    }

    private var showMA: Bool = true
    private var task: Task<Void, Error>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // 这里都是配置布局信息的代码
        view.backgroundColor = .Stockee.background
        chartView.backgroundColor = .Stockee.background
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.configuration.captionPadding.right = 70
        chartView.configuration.upColor = .Stockee.green
        chartView.configuration.downColor = .Stockee.red

        view.addSubview(chartView)
        view.addConstraints([
            chartView.topAnchor.constraint(equalTo: lastStackView.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        // 因为使用 UIScrollView 作为容器，所以可以使用 ScrollView 的一些特性
        chartView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 100)

        // 配置图表
        configureChartDescriptor()

        requestData()
        task = Task {
            await observeSocket()
        }

        chartView.onWillDisplayRange.delegate(on: self) { target, range in
            if range.contains(0), let first = target.chartView.data.first {
                Task {
                    try await target.loadMore(endTime: first.start - 1)
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        task?.cancel()
    }

    @IBAction func chartButtonTapped(_ sender: UIButton) {
        guard let name = sender.titleLabel?.text,
              let opt = ChartOption(name: name)
        else {
            return
        }
        if chartOptions.contains(opt) {
            chartOptions.remove(opt)
            sender.isSelected = false
        } else {
            chartOptions.insert(opt)
            sender.isSelected = true
        }
    }

    @IBAction func timeIntervalChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            interval = "1m"
        case 1:
            interval = "5m"
        case 2:
            interval = "1d"
        case 3:
            interval = "1w"
        default:
            break
        }

        isTimeShare = segmentedControl.selectedSegmentIndex == 0
    }
}

// MARK: - Chart

extension ViewController {
    private var mainChartGroup: ChartGroup<Candle> {
        // 主图，高度为 200， 然后配置默认的 Formatter，用于格式化各种指标
        ChartGroup(height: 200, preferredFormatter: .defaultPrice(), chartPadding: (2, 4)) {
            // 绘制网格
            GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: .Stockee.border)
            // 绘制 Y 轴坐标
            YAxisAnnotation()

            if isTimeShare {
                // 如果为分时图，则绘制分时图
                TimeShareChart(color: .magenta)
            } else {
                // 绘制蜡烛图
                CandlestickChart()
                if chartOptions.contains(.ma) {
                    // 如果包含 ma，则绘制 MA
                    // MA5
                    MAChart(configuration: .init(period: 5, color: .Stockee.indicator1))
                    // MA10
                    MAChart(configuration: .init(period: 10, color: .Stockee.indicator2))
                    // MA30
                    MAChart(configuration: .init(period: 30, color: .Stockee.indicator3))
                }
                if chartOptions.contains(.ema) {
                    // EMA
                    EMAChart(configuration: .init(period: 5, color: .Stockee.indicator1))
                    EMAChart(configuration: .init(period: 10, color: .Stockee.indicator2))
                    EMAChart(configuration: .init(period: 30, color: .Stockee.indicator3))
                }
                if chartOptions.contains(.boll) {
                    // BOLL
                    BOLLChart(configuration: .init(period: 12,
                                                   lowerColor: .Stockee.indicator1,
                                                   middleColor: .Stockee.indicator2,
                                                   upperColor: .Stockee.indicator3))
                }
                if chartOptions.contains(.sar) {
                    // SAR
                    SARChart(configuration: .init(upColor: .Stockee.indicator1, downColor: .Stockee.indicator2, reversalColor: .gray))
                }
                // 绘制最高最低价格指示器
                ExtremePriceIndicator(color: .label)
                // 绘制最新成交价
                LatestPriceIndicator()
            }
            // 绘制 Y 轴选择的指标值
            SelectedYIndicator()
        }
    }

    func configureChartDescriptor() {
        chartView.descriptor = ChartDescriptor(spacing: 0) {
            // 主图
            mainChartGroup
            // X 轴
            ChartGroup(height: 18) {
                // 绘制日期
                TimeAnnotation(dateFormat: "HH:mm")
                // 绘制当前选择的日期
                SelectedTimeIndicator()
            }

            if chartOptions.contains(.vol) {
                // 成交量图表
                ChartGroup(height: 50, preferredFormatter: .volume) {
                    // 绘制网格
                    GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: .Stockee.border)
                    // 同时也要绘制 Y 轴坐标
                    YAxisAnnotation(formatter: .volume)
                    VolumeChart(minHeight: 1)
                    SelectedYIndicator()
                }
            }

            if chartOptions.contains(.macd) {
                // 绘制 macd
                ChartGroup(height: 50, preferredFormatter: .defaultPrice()) {
                    GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: .Stockee.border)
                    YAxisAnnotation(formatter: .maximumSignificantDigits(4))
                    MACDChart(configuration: .init(diffColor: .Stockee.indicator1, deaColor: .Stockee.indicator2))
                    SelectedYIndicator()
                }
            }

            if chartOptions.contains(.kdj) {
                // 绘制 kdj
                ChartGroup(height: 50) {
                    GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: .Stockee.border)
                    YAxisAnnotation(formatter: .maximumFractionDigits(1))
                    KDJChart(configuration: .init(kColor: .Stockee.indicator1,
                                                  dColor: .Stockee.indicator2,
                                                  jColor: .Stockee.indicator3))
                    SelectedYIndicator()
                }
            }

            if chartOptions.contains(.rsi) {
                // 绘制 rsi
                ChartGroup(height: 50) {
                    GridIndicator(lineWidth: 1 / UIScreen.main.scale, color: .Stockee.border)
                    YAxisAnnotation(formatter: .maximumFractionDigits(1))
                    RSIChart(configuration: .init(period: 6, color: .Stockee.indicator1))
                    RSIChart(configuration: .init(period: 12, color: .Stockee.indicator2))
                    RSIChart(configuration: .init(period: 24, color: .Stockee.indicator3))
                    SelectedYIndicator()
                }
            }
        }
    }
}

// MARK: - Network & Data

extension ViewController {
    private func resetDatasource() {
        requestData()
        task?.cancel()
        task = Task {
            await observeSocket()
        }
    }

    private func observeSocket() async {
        let url = "wss://stream.binance.com:9443/ws/\(symbol.lowercased())@kline_\(interval)"
        let request = URLRequest(url: URL(string: url)!)
        do {
            let task = URLSession.shared.webSocketTask(with: request)
            task.resume()
            while !Task.isCancelled {
                let data = try await task.receive().decode(BNWrapper.self)
                handleSocketQuote(data.k)
            }
            task.cancel()
        } catch {
            print("🥵", error)
            task?.cancel()
            task = Task {
                await observeSocket()
            }
        }
    }

    @MainActor private func handleSocketQuote(_ quote: SocketQuote) {
        guard let last = chartView.data.last else {
            print("🥵 request data")
            requestData()
            return
        }
        if last.start == quote.start {
            chartView.replaceLast(quote.candle)
            print("🥵 replace last")
        } else if last.end + 1 == quote.start {
            chartView.append(quote.candle)
            print("🥵 append")
        } else {
            requestData()
            print("🥵 request data")
        }
    }

    private func requestData() {
        Task {
            do {
                try await _requestData()
            } catch {
                print(error)
            }
        }
    }

    private func _requestData() async throws {
        guard !isLoading else { return }
        isLoading = true
        let data = try await BinanceAPI.getKLine(symbol: symbol, interval: interval)
        reloadData(data)
        isLoading = false
    }

    private func loadMore(endTime: Int) async throws {
        guard !isLoading else { return }
        isLoading = true
        let data = try await BinanceAPI.getKLine(symbol: symbol, interval: interval, endTime: endTime)
        preprend(data)
        isLoading = false
    }

    @MainActor
    private func preprend(_ data: [Candle]) {
        guard let last = data.last, let first = chartView.data.first else {
            print("🫠 prepend not allowed")
            return
        }
        guard last.end + 1 == first.start else {
            print("🫠 prepend, time not match")
            return
        }

        print("🫠 prepend", data.count)
        chartView.prepend(data)
    }

    @MainActor
    private func reloadData(_ data: [Candle]) {
        print("===== reload", data.count)
        chartView.reloadData(data)
    }
}

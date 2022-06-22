# Stockee

K 线图

## How To Use

> 可以直接参考 Playground 里的 `ViewController.swift`，有比较完整的 Demo，使用 Binance API 实现了一个丑陋的 K 线图，支持配置指标、加载更多、更新最新报价等功能

### 类

* **ChartView**：渲染 Chart 的容器，接收数据和 配置的 `ChartDescriptor` 来渲染图表；
* **ChartRenderer**：特定的图表渲染器，例如蜡烛图、MA 指标图等；
* **ChartGroup**：包含一组 ChartRenderer，例如：主图就是一个 Group，每个副图也是一个 Group；
* **CharDescriptor**：包含一组 ChartGroup，用于渲染多组图表；
* **Configuration**：基础配置信息，例如，蜡烛图宽度、上升趋势的颜色、标注的字体等。

### 教程

1. 定义报价 `struct`

    ```swift
    // 需要实现 Quote 协议，提供基础的报价信息
    struct Candle: Quote {
    // ....
    }
    ```

2. 创建图表容器 

   ```swift
   // 这里使用范型
   // 因为既不想使用协议存储数据，动态分发对性能会有所影响
   // 也不想自定义一堆结构体，在内存中占用额外的内存，所以，后面很多类都是范型的
   let chartView: ChartView<Candle> = ChartView<Candle>(frame: .zero)
   /// 因为是使用的 UIScrollView 作为容器，所以，可以使用 ScrollView 的一些特性，例如在四周留出更多的空白空间
   chartView.contentInset = .init(top: 16, left: 16, bottom: 16, right: 100)
   ```
   
3. 配置信息

    ```swift
    chartView.configuration.barWidth = 4
    chartView.configuration.style.upColor = .red
    // 或者
    chartView.configuration = newConfiguration
    ```

    * 包含一些影响整个 Chart 渲染的配置信息，例如：每个 Candle 的宽度，上升趋势的颜色等, 更多配置信息可以参考 `Configuration` 这个结构体。

4. 配置 `ChartDescriptor`

    * 这里配置各种指标图表或者辅助图表，会直接影响到 K 线图的排版，层级等；
    * 实现了一个简单的 `DSL`，可以使用类似 `SwiftUI` 的方式组织图表；
    * `ChartView` 需要一个 `ChartDescriptor` 来了解该如何渲染多组图表。
      * `ChartDescriptor` 是一组 `ChartGroup` 的集合 Chart 会自上而下的渲染多个 Group；
      * 一个 `ChartGroup` 是一组 `ChartRenderer` 的集合，一个 group 的 chart 会渲染在同一个区域，会沿着 Z 轴自下而上的排列，意味着，`ChartRenderer` 在数组中的 Index 越大，它的 `zPosition` 也就越大；
      * `ChartRenderer` 是一个 `protocol`，用于渲染一个特定的图表（例如：蜡烛图、EMA 指标、MACD 指标等），具体参考 [目前支持的 ChartRenderer](#目前支持的-chartrenderer) ；

    ```swift
    chartView.descriptor = ChartDescriptor(spacing: 0) {
        // 主图，高度为 200， 然后配置默认的 Formatter，用于格式化各种指标
        ChartGroup(height: 200, preferredFormatter: .defaultPrice(), chartPadding: (2, 4)) {
            // 绘制网格
            GridIndicator(lineWidth: 1/UIScreen.main.scale, color: UIColor(white: 0.8, alpha: 1))
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
                    // MA6
                    MAChart(configuration: .init(period: 6, color: .systemBrown))
                    // MA12
                    MAChart(configuration: .init(period: 12, color: .systemPink))
                }
            }
            // ... 绘制更多指标
        }
    
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
                GridIndicator(lineWidth: 1/UIScreen.main.scale, color: UIColor(white: 0.8, alpha: 1))
                // 同时也要绘制 Y 轴坐标
                YAxisAnnotation(formatter: .volume)
                VolumeChart(minHeight: 1)
                SelectedYIndicator()
            }
        }
    }
    ```
    
    * 这里展示了一部分配置信息，更完整的可以参考 `ViewController.swift`；
    * 建立每个 `ChartGroup` 可以用一个计算属性进行配置；
    * 然后使用一个计算属性 `descriptor` 来组合这些 `groups`；
    * 本库是一个绘制图表的通用库，建议单独建一个 `Pod` 机遇这个库实现一个 `Bitmart` 的 K 线图；可以继承 `ChartRenderer` 进行一些自定义的绘制，例如：绘制水印等
    
5. 数据
    ```swift
    // 重新加载数据，图表会重新渲染，不保留滚动 Offset
    chartView.reloadData(data)
    // 在当前数据之前，添加新的数据，会保留滚动 Offset
    chartView.prepend(data)
    // 替换最后一个 Quote，会保留滚动 Offset
    chartView.replaceLast(quote)
    ```



> 可以把 `CharView` 看作是一个可以渲染多组图表的一个容器，其本身并不关心每个图表（例如：MA 指标）是如何处数据和渲染图表的，ChartView 会在数据发生改变后，把数据交付给每个图表的数据处理器进行处理，然后把数据存储在 `ContextValues` 中，然后在渲染阶段，把布局信息和 ContextValue 交给具体的 Chart 进行渲染。



### 目前支持的 ChartRenderer

#### 主图

- `CandlestickChart`： 蜡烛图
- `TimeShareChart`：分时图
- `SARChart`：SAR 指标
- `MAChart`：MA 指标
- `EMAChart`：EMA 指标
- `BOLLChart`：BOLL 指标

#### 副图

* `VolumeChart`：成交量
* `KDJChart`：KDJ 指标
* `MACDChart`：MACD 指标
* `RSIChart`：RSI 指标

#### 辅助

* `ExtremePriceIndicator`：最低、最高成交价
* `GridIndicator`：网格
* `LatestPriceIndicator`：最新成交价
* `SelectedTimeIndicator`： 当前选择的 Quote 的日期
* `SelectedYIndicator`：当前选择的 Y 轴的值
* `TimeAnnotation`：X 轴标注，也就是日期
* `YAxisAnnotation`：Y 轴的标注
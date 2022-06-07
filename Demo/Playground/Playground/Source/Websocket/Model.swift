import Stockee
import UIKit

public struct SocketQuote: Quote {
    public var date: Date
    public var start: Int
    public var end: Int
    public var low: CGFloat
    public var high: CGFloat
    public var open: CGFloat
    public var close: CGFloat
    public var volume: CGFloat
}

extension SocketQuote: Decodable {
    enum CodingKeys: String, CodingKey {
        case start = "t"
        case end = "T"
        case open = "o"
        case close = "c"
        case high = "h"
        case low = "l"
        case volume = "v"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.start = try container.decode(Int.self, forKey: .start)
        self.end = try container.decode(Int.self, forKey: .end)
        self.date = Date(timeIntervalSince1970: CGFloat(start) / 1000)
        self.low = try Double(container.decode(String.self, forKey: .low))!
        self.high = try Double(container.decode(String.self, forKey: .high))!
        self.open = try Double(container.decode(String.self, forKey: .open))!
        self.close = try Double(container.decode(String.self, forKey: .close))!
        self.volume = try Double(container.decode(String.self, forKey: .volume))!
    }

    var candle: Candle {
        .init(date: date,
              start: start,
              end: end,
              low: low,
              high: high,
              open: open,
              close: close,
              volume: volume)
    }
}

public struct BNWrapper: Decodable {
    // swiftlint:disable identifier_name
    public var k: SocketQuote
}

public struct BNQuote: Quote {
    public var date: Date
    public var start: Int
    public var end: Int
    public var low: CGFloat
    public var high: CGFloat
    public var open: CGFloat
    public var close: CGFloat
    public var volume: CGFloat
}

extension BNQuote: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.start = try container.decode(Int.self)
        self.date = Date(timeIntervalSince1970: CGFloat(start) / 1000)
        self.open = try Double(container.decode(String.self))!
        self.high = try Double(container.decode(String.self))!
        self.low = try Double(container.decode(String.self))!
        self.close = try Double(container.decode(String.self))!
        self.volume = try Double(container.decode(String.self))!
        self.end = try container.decode(Int.self)
    }

    var candle: Candle {
        .init(date: date,
              start: start,
              end: end,
              low: low,
              high: high,
              open: open,
              close: close,
              volume: volume)
    }
}

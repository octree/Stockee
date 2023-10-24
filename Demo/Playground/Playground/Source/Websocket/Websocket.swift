//
//  Websocket.swift
//  Stockee
//
//  Created by octree on 2022/3/19.
//
// Copyright (c) 2022 Octree <fouljz@gmail.com>
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

import Foundation

extension URLSessionWebSocketTask.Message {
    private var data: Data {
        switch self {
        case let .data(data):
            return data
        case let .string(string):
            return string.data(using: .utf8)!
        @unknown default:
            fatalError()
        }
    }

    func decode<E: Decodable>(_ type: E.Type) throws -> E {
        try JSONDecoder().decode(E.self, from: data)
    }
}

enum BinanceAPI {
    static func getKLine(symbol: String,
                         interval: String,
                         endTime: Int? = nil,
                         limit: Int = 500) async throws -> [Candle] {
        var query = "symbol=\(symbol)&interval=\(interval)&limit=\(limit)"
        if let endTime = endTime {
            query += "&endTime=\(endTime)"
        }
        let url = URL(string: "https://api.binance.com/api/v3/klines?\(query)")!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession(configuration: .default).data(for: request)
        return try JSONDecoder().decode([BNQuote].self, from: data).map { $0.candle }
    }
}

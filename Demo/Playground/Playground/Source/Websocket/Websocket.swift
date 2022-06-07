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
import Starscream

public enum StreamError: Error {
    case unkown
    case disconnected(code: Int, reason: String)
}

public final class CodableStreamClient<Element: Decodable> {
    private var socket: WebSocket
    var isConnected: Bool = false
    var onReceive: ((Element) -> Void)?
    var onComplete: (() -> Void)?
    var onError: ((Error) -> Void)?
    public init(request: URLRequest) {
        socket = WebSocket(request: request)
        socket.delegate = self
    }

    public func connect() {
        guard !isConnected else { return }
        socket.connect()
    }

    public func disconnect() {
        guard isConnected else { return }
        socket.disconnect()
    }

    private func handleData(_ data: Data) {
        do {
            try onReceive?(JSONDecoder().decode(Element.self, from: data))
        } catch {
            onError?(error)
            disconnect()
        }
    }
}

extension CodableStreamClient: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case let .connected(headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case let .disconnected(reason, code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case let .text(string):
            print("Received text")
            handleData(string.data(using: .utf8)!)
        case let .binary(data):
            print("Received data: \(data.count)")
            handleData(data)
        case .ping:
            print("ping")
        case .pong:
            print("pong")
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isConnected = false
        case let .error(error):
            isConnected = false
            handleError(error)
        }
    }

    private func handleError(_ error: Error?) {
        onError?(error ?? StreamError.unkown)
    }
}

public struct CodableStream<E: Decodable> {
    private var client: CodableStreamClient<E>
    public init(request: URLRequest) {
        client = .init(request: request)
    }

    public var stream: AsyncThrowingStream<E, Error> {
        .init(E.self, bufferingPolicy: .bufferingNewest(1)) { contination in
            client.onError = { contination.finish(throwing: $0) }
            client.onReceive = { contination.yield($0) }
            client.onComplete = { contination.finish() }
            client.connect()
        }
    }
}

enum BinanceAPI {
    static func getKLine(symbol: String,
                         interval: String,
                         endTime: Int? = nil,
                         limit: Int = 500) async throws -> [Candle]
    {
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

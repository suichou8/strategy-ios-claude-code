//
//  RealTimeModels.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// 实时数据
public struct RealTimeData: Codable, Identifiable, Equatable, Sendable {
    public var id: String { symbol }

    /// 股票代码
    public let symbol: String

    /// 股票名称
    public let name: String

    /// 开盘价
    public let openPrice: Double?

    /// 前收盘价
    public let previousClose: Double?

    /// 当前价格
    public let currentPrice: Double?

    /// 最高价
    public let highPrice: Double?

    /// 最低价
    public let lowPrice: Double?

    /// 成交量
    public let volume: Int?

    /// 涨跌额
    public let change: Double?

    /// 涨跌幅百分比
    public let changePercent: Double?

    /// 时间戳
    public let timestamp: String

    /// 货币单位
    public let currency: String

    public init(
        symbol: String,
        name: String = "",
        openPrice: Double? = nil,
        previousClose: Double? = nil,
        currentPrice: Double? = nil,
        highPrice: Double? = nil,
        lowPrice: Double? = nil,
        volume: Int? = nil,
        change: Double? = nil,
        changePercent: Double? = nil,
        timestamp: String,
        currency: String = "USD"
    ) {
        self.symbol = symbol
        self.name = name
        self.openPrice = openPrice
        self.previousClose = previousClose
        self.currentPrice = currentPrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.volume = volume
        self.change = change
        self.changePercent = changePercent
        self.timestamp = timestamp
        self.currency = currency
    }
}

/// 实时数据响应
public struct RealTimeResponse: Codable, Sendable {
    public let success: Bool
    public let message: String
    public let timestamp: String
    public let realTimeData: [String: RealTimeData]

    public init(
        success: Bool,
        message: String,
        timestamp: String,
        realTimeData: [String: RealTimeData]
    ) {
        self.success = success
        self.message = message
        self.timestamp = timestamp
        self.realTimeData = realTimeData
    }
}

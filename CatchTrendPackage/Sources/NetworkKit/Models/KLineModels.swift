//
//  KLineModels.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// K 线数据项
public struct KLineItem: Codable, Identifiable, Equatable, Sendable {
    public let id = UUID()

    /// 时间
    public let datetime: String

    /// 开盘价
    public let open: Double?

    /// 最高价
    public let high: Double?

    /// 最低价
    public let low: Double?

    /// 收盘价
    public let close: Double?

    /// 成交量
    public let volume: Int?

    public init(
        datetime: String,
        open: Double? = nil,
        high: Double? = nil,
        low: Double? = nil,
        close: Double? = nil,
        volume: Int? = nil
    ) {
        self.datetime = datetime
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case datetime
        case open
        case high
        case low
        case close
        case volume
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        datetime = try container.decode(String.self, forKey: .datetime)
        open = try container.decodeIfPresent(Double.self, forKey: .open)
        high = try container.decodeIfPresent(Double.self, forKey: .high)
        low = try container.decodeIfPresent(Double.self, forKey: .low)
        close = try container.decodeIfPresent(Double.self, forKey: .close)
        volume = try container.decodeIfPresent(Int.self, forKey: .volume)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(datetime, forKey: .datetime)
        try container.encodeIfPresent(open, forKey: .open)
        try container.encodeIfPresent(high, forKey: .high)
        try container.encodeIfPresent(low, forKey: .low)
        try container.encodeIfPresent(close, forKey: .close)
        try container.encodeIfPresent(volume, forKey: .volume)
    }

    // MARK: - Equatable

    public static func == (lhs: KLineItem, rhs: KLineItem) -> Bool {
        return lhs.datetime == rhs.datetime &&
               lhs.open == rhs.open &&
               lhs.high == rhs.high &&
               lhs.low == rhs.low &&
               lhs.close == rhs.close &&
               lhs.volume == rhs.volume
    }
}

/// K 线数据
public struct KLineData: Codable, Equatable, Sendable {
    /// 股票代码
    public let symbol: String

    /// 时间周期
    public let period: String

    /// K 线数据列表
    public let data: [KLineItem]

    /// 数据条数
    public let count: Int

    /// 获取时间
    public let fetchTime: String

    public init(
        symbol: String,
        period: String,
        data: [KLineItem],
        count: Int,
        fetchTime: String
    ) {
        self.symbol = symbol
        self.period = period
        self.data = data
        self.count = count
        self.fetchTime = fetchTime
    }
}

/// K 线响应
public struct KLineResponse: Codable, Sendable {
    public let success: Bool
    public let message: String
    public let timestamp: String
    public let klineData: KLineData?

    public init(
        success: Bool,
        message: String,
        timestamp: String,
        klineData: KLineData? = nil
    ) {
        self.success = success
        self.message = message
        self.timestamp = timestamp
        self.klineData = klineData
    }
}

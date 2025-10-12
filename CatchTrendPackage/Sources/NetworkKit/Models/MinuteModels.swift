//
//  MinuteModels.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// 分时数据项
public struct MinuteItem: Codable, Identifiable, Equatable, Sendable {
    public let id = UUID()

    /// 时间
    public let time: String

    /// 价格
    public let price: Double?

    /// 成交量
    public let volume: Int?

    /// 均价
    public let avgPrice: Double?

    public init(
        time: String,
        price: Double? = nil,
        volume: Int? = nil,
        avgPrice: Double? = nil
    ) {
        self.time = time
        self.price = price
        self.volume = volume
        self.avgPrice = avgPrice
    }

    // MARK: - Equatable

    public static func == (lhs: MinuteItem, rhs: MinuteItem) -> Bool {
        return lhs.time == rhs.time &&
               lhs.price == rhs.price &&
               lhs.volume == rhs.volume &&
               lhs.avgPrice == rhs.avgPrice
    }
}

/// 分时数据
public struct MinuteData: Codable, Equatable, Sendable {
    /// 股票代码
    public let symbol: String

    /// 日期
    public let date: String

    /// 分时数据列表
    public let data: [MinuteItem]

    /// 数据条数
    public let count: Int

    /// 获取时间
    public let fetchTime: String

    public init(
        symbol: String,
        date: String,
        data: [MinuteItem],
        count: Int,
        fetchTime: String
    ) {
        self.symbol = symbol
        self.date = date
        self.data = data
        self.count = count
        self.fetchTime = fetchTime
    }
}

/// 分时响应
public struct MinuteResponse: Codable, Sendable {
    public let success: Bool
    public let message: String
    public let timestamp: String
    public let minuteData: MinuteData?

    public init(
        success: Bool,
        message: String,
        timestamp: String,
        minuteData: MinuteData? = nil
    ) {
        self.success = success
        self.message = message
        self.timestamp = timestamp
        self.minuteData = minuteData
    }
}

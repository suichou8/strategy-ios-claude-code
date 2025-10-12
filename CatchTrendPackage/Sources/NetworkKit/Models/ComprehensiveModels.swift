//
//  ComprehensiveModels.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// 综合股票数据
public struct ComprehensiveData: Codable, Equatable, Sendable {
    /// 股票代码
    public let symbol: String

    /// 获取时间
    public let fetchTime: String

    /// 实时数据
    public let realTime: RealTimeData?

    /// 日 K 线数据
    public let dailyKline: KLineData?

    /// 分钟 K 线数据
    public let minuteKline: KLineData?

    /// 分时数据
    public let minuteData: MinuteData?

    /// 错误列表
    public let errors: [String]

    public init(
        symbol: String,
        fetchTime: String,
        realTime: RealTimeData? = nil,
        dailyKline: KLineData? = nil,
        minuteKline: KLineData? = nil,
        minuteData: MinuteData? = nil,
        errors: [String] = []
    ) {
        self.symbol = symbol
        self.fetchTime = fetchTime
        self.realTime = realTime
        self.dailyKline = dailyKline
        self.minuteKline = minuteKline
        self.minuteData = minuteData
        self.errors = errors
    }
}

/// 综合数据响应（完整版本）
public struct ComprehensiveResponse: Codable, Sendable {
    /// 请求是否成功
    public let success: Bool

    /// 响应消息
    public let message: String

    /// 响应时间戳
    public let timestamp: String

    /// 综合数据
    public let comprehensiveData: ComprehensiveData?

    public init(
        success: Bool,
        message: String,
        timestamp: String,
        comprehensiveData: ComprehensiveData? = nil
    ) {
        self.success = success
        self.message = message
        self.timestamp = timestamp
        self.comprehensiveData = comprehensiveData
    }
}

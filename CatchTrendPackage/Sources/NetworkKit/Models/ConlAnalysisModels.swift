//
//  ConlAnalysisModels.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/11/09.
//

import Foundation

// MARK: - CONL Analysis Response

/// CONL 分析响应
public struct ConlAnalysisResponse: Codable, Sendable {
    /// 分析日期
    public let date: String

    /// 交易摘要
    public let summary: TradingSummary

    /// 叙述分析（分时段描述）
    public let narrative: Narrative?

    /// 交易单元（详细的分时段数据）
    public let units: [TradingUnit]?

    public init(
        date: String,
        summary: TradingSummary,
        narrative: Narrative? = nil,
        units: [TradingUnit]? = nil
    ) {
        self.date = date
        self.summary = summary
        self.narrative = narrative
        self.units = units
    }
}

// MARK: - Trading Summary

/// 交易摘要
public struct TradingSummary: Codable, Sendable {
    /// 开盘价
    public let open: Double

    /// 收盘价
    public let close: Double

    /// 昨日收盘价
    public let prevClose: Double

    /// 当日最高价
    public let dayHigh: Double

    /// 当日最高价相对昨收涨幅百分比
    public let dayHighPct: Double

    /// 开盘跳空百分比
    public let gapOpenPct: Double

    /// 收盘涨跌幅百分比
    public let closeChangePct: Double

    /// 文字描述
    public let text: String

    public init(
        open: Double,
        close: Double,
        prevClose: Double,
        dayHigh: Double,
        dayHighPct: Double,
        gapOpenPct: Double,
        closeChangePct: Double,
        text: String
    ) {
        self.open = open
        self.close = close
        self.prevClose = prevClose
        self.dayHigh = dayHigh
        self.dayHighPct = dayHighPct
        self.gapOpenPct = gapOpenPct
        self.closeChangePct = closeChangePct
        self.text = text
    }
}

// MARK: - Narrative

/// 叙述分析（分时段）
public struct Narrative: Codable, Sendable {
    /// 早盘分析
    public let early: String?

    /// 午盘分析
    public let midday: String?

    /// 午后分析
    public let afternoon: String?

    /// 尾盘分析
    public let closing: String?

    public init(
        early: String? = nil,
        midday: String? = nil,
        afternoon: String? = nil,
        closing: String? = nil
    ) {
        self.early = early
        self.midday = midday
        self.afternoon = afternoon
        self.closing = closing
    }
}

// MARK: - Trading Unit

/// 交易单元（某个时间段的详细数据）
public struct TradingUnit: Codable, Sendable {
    /// 单元索引
    public let index: Int

    /// 时间
    public let time: String

    /// 起始价格
    public let priceFrom: Double

    /// 结束价格
    public let priceTo: Double

    /// 价格变化百分比
    public let priceChangePct: Double

    /// 成交量变化百分比
    public let volumeChangePct: Double

    /// 关系类型（缩量涨、放量跌等）
    public let relationship: String

    /// 关系描述
    public let relationshipDesc: String

    public init(
        index: Int,
        time: String,
        priceFrom: Double,
        priceTo: Double,
        priceChangePct: Double,
        volumeChangePct: Double,
        relationship: String,
        relationshipDesc: String
    ) {
        self.index = index
        self.time = time
        self.priceFrom = priceFrom
        self.priceTo = priceTo
        self.priceChangePct = priceChangePct
        self.volumeChangePct = volumeChangePct
        self.relationship = relationship
        self.relationshipDesc = relationshipDesc
    }
}

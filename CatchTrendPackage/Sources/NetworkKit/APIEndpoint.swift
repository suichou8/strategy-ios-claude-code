//
//  APIEndpoint.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// HTTP 请求方法
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// API 端点定义
public enum APIEndpoint {
    /// 用户登录
    case login(username: String, password: String)

    /// 获取综合股票数据
    case comprehensive(symbol: String, timestamp: Int?)

    /// 获取 K 线数据
    case kline(symbol: String, period: String, count: Int, timestamp: Int)

    /// 获取分时数据
    case minute(symbol: String, date: String?, timestamp: Int)

    /// 获取实时数据
    case realtime(symbols: [String], timestamp: Int)

    /// CONL 分析 - 最新交易日
    case conlAnalysisLatest(klineType: String, includeMarketContext: Bool, timestamp: Int?)

    /// CONL 分析 - 指定日期
    case conlAnalysisDate(date: String, includeMarketContext: Bool, timestamp: Int?)
}

extension APIEndpoint {
    /// HTTP 方法
    public var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .comprehensive, .conlAnalysisLatest, .conlAnalysisDate:
            return .get
        case .kline, .minute, .realtime:
            return .post
        }
    }

    /// 请求路径
    public var path: String {
        switch self {
        case .login:
            return "/api/v1/stocks/auth/login"
        case .comprehensive(let symbol, _):
            return "/api/v1/stocks/\(symbol)/comprehensive"
        case .kline:
            return "/api/v1/stocks/kline"
        case .minute:
            return "/api/v1/stocks/minute"
        case .realtime:
            return "/api/v1/stocks/realtime"
        case .conlAnalysisLatest:
            return "/api/v1/analyze/conl/latest"
        case .conlAnalysisDate(let date, _, _):
            return "/api/v1/analyze/conl/\(date)"
        }
    }

    /// 是否需要认证
    public var requiresAuth: Bool {
        switch self {
        case .login:
            return false
        case .comprehensive, .kline, .minute, .realtime, .conlAnalysisLatest, .conlAnalysisDate:
            return true
        }
    }

    /// 请求体参数
    public var body: Encodable? {
        switch self {
        case .login(let username, let password):
            return LoginRequest(username: username, password: password)

        case .comprehensive, .conlAnalysisLatest, .conlAnalysisDate:
            return nil

        case .kline(let symbol, let period, let count, let timestamp):
            return KLineRequest(symbol: symbol, period: period, count: count, timestamp: timestamp)

        case .minute(let symbol, let date, let timestamp):
            return MinuteRequest(symbol: symbol, date: date, timestamp: timestamp)

        case .realtime(let symbols, let timestamp):
            return RealtimeRequest(symbols: symbols, timestamp: timestamp)
        }
    }

    /// 查询参数（用于 GET 请求）
    public var queryItems: [URLQueryItem]? {
        switch self {
        case .comprehensive(_, let timestamp):
            if let timestamp = timestamp {
                return [URLQueryItem(name: "timestamp", value: "\(timestamp)")]
            }
            return nil

        case .conlAnalysisLatest(let klineType, let includeMarketContext, let timestamp):
            var items = [
                URLQueryItem(name: "kline_type", value: klineType),
                URLQueryItem(name: "include_market_context", value: includeMarketContext ? "true" : "false")
            ]
            if let timestamp = timestamp {
                items.append(URLQueryItem(name: "_t", value: "\(timestamp)"))
            }
            return items

        case .conlAnalysisDate(_, let includeMarketContext, let timestamp):
            var items = [
                URLQueryItem(name: "include_market_context", value: includeMarketContext ? "true" : "false")
            ]
            if let timestamp = timestamp {
                items.append(URLQueryItem(name: "_t", value: "\(timestamp)"))
            }
            return items

        default:
            return nil
        }
    }
}

// MARK: - Request Models

/// 登录请求
private struct LoginRequest: Encodable {
    let username: String
    let password: String
}

/// K 线请求
private struct KLineRequest: Encodable {
    let symbol: String
    let period: String
    let count: Int
    let timestamp: Int
}

/// 分时请求
private struct MinuteRequest: Encodable {
    let symbol: String
    let date: String?
    let timestamp: Int
}

/// 实时数据请求
private struct RealtimeRequest: Encodable {
    let symbols: [String]
    let timestamp: Int
}

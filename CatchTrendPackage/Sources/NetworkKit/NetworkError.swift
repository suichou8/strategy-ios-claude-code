//
//  NetworkError.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// 网络请求错误类型
public enum NetworkError: Error, LocalizedError {
    /// 无效的 URL
    case invalidURL

    /// 无效的响应
    case invalidResponse

    /// HTTP 错误（状态码）
    case httpError(statusCode: Int)

    /// 解码失败
    case decodingError(Error)

    /// 编码失败
    case encodingError(Error)

    /// 未授权（401）
    case unauthorized

    /// 请求频率限制（429）
    case rateLimited

    /// 服务器错误（5xx）
    case serverError(statusCode: Int)

    /// 网络连接失败
    case networkFailure(Error)

    /// 超时
    case timeout

    /// 未知错误
    case unknown(Error)

    /// 错误描述
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .httpError(let statusCode):
            return "HTTP 错误：\(statusCode)"
        case .decodingError(let error):
            return "数据解码失败：\(error.localizedDescription)"
        case .encodingError(let error):
            return "数据编码失败：\(error.localizedDescription)"
        case .unauthorized:
            return "未授权，请先登录"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .serverError(let statusCode):
            return "服务器错误：\(statusCode)"
        case .networkFailure(let error):
            return "网络连接失败：\(error.localizedDescription)"
        case .timeout:
            return "请求超时"
        case .unknown(let error):
            return "未知错误：\(error.localizedDescription)"
        }
    }
}

//
//  APIConfig.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// API 配置
public enum APIConfig {
    /// API Base URL
    public static var baseURL: String {
        #if DEBUG
        // 开发环境 - 可以在这里切换到本地服务器测试
        // return "http://localhost:8000"
        return "https://strategy-claude-code.vercel.app"
        #else
        // 生产环境
        return "https://strategy-claude-code.vercel.app"
        #endif
    }

    /// 请求超时时间（秒）
    public static let timeout: TimeInterval = 30

    /// 是否启用日志
    public static var enableLogging: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}

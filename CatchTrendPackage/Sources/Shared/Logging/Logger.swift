//
//  Logger.swift
//  Shared
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation
import OSLog

/// 应用程序统一日志系统
///
/// 基于 os.Logger 实现，提供结构化日志记录功能。
/// 只在 DEBUG 模式下输出日志，RELEASE 模式下自动禁用。
///
/// ## 特性
/// - 自动捕获调用位置信息（文件名、函数名、行号）
/// - 支持多种日志级别（debug, info, notice, warning, error, fault）
/// - 按子系统和类别组织日志
/// - 零性能开销（RELEASE 模式下完全移除）
///
/// ## 使用示例
/// ```swift
/// // 创建 Logger 实例
/// let logger = Logger.make(category: "Network")
///
/// // 记录不同级别的日志
/// logger.debug("开始网络请求")
/// logger.info("请求成功")
/// logger.warning("响应较慢")
/// logger.error("请求失败", error: error)
/// ```
public struct Logger: Sendable {
    // MARK: - Properties

    /// 底层 OSLog Logger
    private let osLogger: os.Logger

    /// 是否启用日志（仅在 DEBUG 模式下启用）
    private static var isEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    // MARK: - Initialization

    /// 创建 Logger 实例
    ///
    /// - Parameters:
    ///   - subsystem: 子系统标识符，通常使用 Bundle ID
    ///   - category: 日志类别，用于分组相关日志
    private init(subsystem: String, category: String) {
        self.osLogger = os.Logger(subsystem: subsystem, category: category)
    }

    /// 便捷工厂方法：使用默认子系统创建 Logger
    ///
    /// - Parameter category: 日志类别
    /// - Returns: Logger 实例
    public static func make(category: String) -> Logger {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.catchtrend.app"
        return Logger(subsystem: subsystem, category: category)
    }

    // MARK: - Logging Methods

    /// 记录调试信息
    ///
    /// 用于记录详细的调试信息，帮助开发过程中追踪程序执行流程。
    ///
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 调用文件（自动捕获）
    ///   - function: 调用函数（自动捕获）
    ///   - line: 调用行号（自动捕获）
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .debug,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// 记录一般信息
    ///
    /// 用于记录程序运行的一般信息。
    ///
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 调用文件（自动捕获）
    ///   - function: 调用函数（自动捕获）
    ///   - line: 调用行号（自动捕获）
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .info,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// 记录提醒信息
    ///
    /// 用于记录需要注意的事件，但不是错误。
    ///
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 调用文件（自动捕获）
    ///   - function: 调用函数（自动捕获）
    ///   - line: 调用行号（自动捕获）
    public func notice(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .notice,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// 记录警告信息
    ///
    /// 用于记录可能导致问题的事件。
    ///
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 调用文件（自动捕获）
    ///   - function: 调用函数（自动捕获）
    ///   - line: 调用行号（自动捕获）
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            level: .warning,
            message: message,
            file: file,
            function: function,
            line: line
        )
    }

    /// 记录错误信息
    ///
    /// 用于记录已知的错误。
    ///
    /// - Parameters:
    ///   - message: 日志消息
    ///   - error: 可选的 Error 对象
    ///   - file: 调用文件（自动捕获）
    ///   - function: 调用函数（自动捕获）
    ///   - line: 调用行号（自动捕获）
    public func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fullMessage = if let error = error {
            "\(message) | Error: \(error.localizedDescription)"
        } else {
            message
        }

        log(
            level: .error,
            message: fullMessage,
            file: file,
            function: function,
            line: line
        )
    }

    /// 记录严重错误信息
    ///
    /// 用于记录可能导致程序崩溃的严重错误。
    ///
    /// - Parameters:
    ///   - message: 日志消息
    ///   - error: 可选的 Error 对象
    ///   - file: 调用文件（自动捕获）
    ///   - function: 调用函数（自动捕获）
    ///   - line: 调用行号（自动捕获）
    public func fault(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fullMessage = if let error = error {
            "\(message) | Error: \(error.localizedDescription)"
        } else {
            message
        }

        log(
            level: .fault,
            message: fullMessage,
            file: file,
            function: function,
            line: line
        )
    }

    // MARK: - Private Methods

    /// 内部日志记录方法
    ///
    /// - Parameters:
    ///   - level: 日志级别
    ///   - message: 日志消息
    ///   - file: 调用文件
    ///   - function: 调用函数
    ///   - line: 调用行号
    private func log(
        level: LogLevel,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let location = "[\(fileName):\(line)] \(function)"

        let formattedMessage = """
        \(level.emoji) [\(level.rawValue.uppercased())] \(location)
        → \(message)
        """

        // 使用对应的 OSLog 级别
        switch level {
        case .debug:
            osLogger.debug("\(formattedMessage, privacy: .public)")
        case .info:
            osLogger.info("\(formattedMessage, privacy: .public)")
        case .notice:
            osLogger.notice("\(formattedMessage, privacy: .public)")
        case .warning:
            osLogger.warning("\(formattedMessage, privacy: .public)")
        case .error:
            osLogger.error("\(formattedMessage, privacy: .public)")
        case .fault:
            osLogger.fault("\(formattedMessage, privacy: .public)")
        }
        #endif
    }
}

// MARK: - LogLevel

extension Logger {
    /// 日志级别
    public enum LogLevel: String {
        case debug
        case info
        case notice
        case warning
        case error
        case fault

        /// 日志级别对应的 emoji
        var emoji: String {
            switch self {
            case .debug:
                return "🔍"
            case .info:
                return "ℹ️"
            case .notice:
                return "📌"
            case .warning:
                return "⚠️"
            case .error:
                return "❌"
            case .fault:
                return "💥"
            }
        }
    }
}

// MARK: - Convenience Extensions

extension Logger {
    /// 预定义的常用 Logger 实例
    public enum Category {
        /// 网络相关日志
        public static let network = Logger.make(category: "Network")

        /// 认证相关日志
        public static let auth = Logger.make(category: "Authentication")

        /// 数据库相关日志
        public static let database = Logger.make(category: "Database")

        /// UI 相关日志
        public static let ui = Logger.make(category: "UI")

        /// 应用生命周期日志
        public static let app = Logger.make(category: "App")

        /// 通用日志
        public static let `default` = Logger.make(category: "Default")
    }
}

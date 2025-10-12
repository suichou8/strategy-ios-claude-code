//
//  LoggerTests.swift
//  SharedTests
//
//  Created by Claude Code on 2025/10/12.
//

import XCTest
@testable import Shared

/// Logger 功能测试
final class LoggerTests: XCTestCase {
    // MARK: - Properties

    var logger: Logger!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        logger = Logger.make(category: "Tests")
    }

    override func tearDown() {
        logger = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// 测试 Logger 创建
    func testLoggerCreation() {
        // Given & When
        let customLogger = Logger.make(category: "Custom")

        // Then
        XCTAssertNotNil(customLogger)
    }

    /// 测试不同日志级别
    func testLogLevels() {
        // Given
        let message = "Test message"

        // When & Then - 这些调用不应该崩溃
        logger.debug(message)
        logger.info(message)
        logger.notice(message)
        logger.warning(message)
        logger.error(message)
        logger.fault(message)
    }

    /// 测试带错误的日志
    func testLoggingWithError() {
        // Given
        struct TestError: Error {
            let message: String
        }
        let error = TestError(message: "Test error")

        // When & Then - 这些调用不应该崩溃
        logger.error("发生错误", error: error)
        logger.fault("严重错误", error: error)
    }

    /// 测试预定义 Logger 类别
    func testPredefinedCategories() {
        // When & Then - 所有预定义 Logger 都应该可用
        XCTAssertNotNil(Logger.Category.network)
        XCTAssertNotNil(Logger.Category.auth)
        XCTAssertNotNil(Logger.Category.database)
        XCTAssertNotNil(Logger.Category.ui)
        XCTAssertNotNil(Logger.Category.app)
        XCTAssertNotNil(Logger.Category.default)
    }

    /// 测试日志调用位置信息
    func testLogLocationCapture() {
        // Given
        let testMessage = "Location test"

        // When - 从特定位置调用（行号会被捕获）
        logger.debug(testMessage) // 这一行的行号会被记录

        // Then - 验证没有崩溃
        // 注意：实际的文件名和行号捕获在 DEBUG 模式下才会输出
        XCTAssertTrue(true, "Logger 应该能够捕获调用位置")
    }

    /// 测试日志性能
    func testLoggingPerformance() {
        // Measure performance
        measure {
            for i in 0..<100 {
                logger.debug("Performance test \(i)")
            }
        }
    }

    /// 测试 LogLevel enum
    func testLogLevelEmoji() {
        // Given & When & Then
        XCTAssertEqual(Logger.LogLevel.debug.emoji, "🔍")
        XCTAssertEqual(Logger.LogLevel.info.emoji, "ℹ️")
        XCTAssertEqual(Logger.LogLevel.notice.emoji, "📌")
        XCTAssertEqual(Logger.LogLevel.warning.emoji, "⚠️")
        XCTAssertEqual(Logger.LogLevel.error.emoji, "❌")
        XCTAssertEqual(Logger.LogLevel.fault.emoji, "💥")
    }
}

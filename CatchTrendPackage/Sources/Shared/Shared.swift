//
//  Shared.swift
//  Shared
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// Shared 模块
///
/// 提供应用程序的共享基础设施和工具：
/// - 日志系统（基于 os.Logger）
/// - ChatGPT 服务（Chat Completions API）
/// - Responses API 服务（用于 o3/o4 推理模型）
/// - 通用扩展
/// - 工具类
///
/// ## 使用方式
/// ```swift
/// import Shared
///
/// // 使用预定义的 Logger
/// let logger = Logger.Category.network
/// logger.info("网络请求开始")
///
/// // 或创建自定义 Logger
/// let customLogger = Logger.make(category: "MyFeature")
/// customLogger.debug("调试信息")
///
/// // 使用 ChatGPT 服务（标准模型）
/// let service = ChatGPTService.shared
/// let result = try await service.chat(
///     systemPrompt: "You are a helpful assistant",
///     userMessage: "Hello"
/// )
///
/// // 使用 Responses API（o3/o4 推理模型）
/// let responsesService = ResponsesAPIService.shared
/// let (content, reasoning) = try await responsesService.reasoning(
///     instructions: "You are a helpful assistant",
///     input: "Analyze this complex problem",
///     reasoning: .auto
/// )
/// ```
public enum Shared {
    /// 模块版本
    public static let version = "1.0.0"
}

// MARK: - Public Exports

// Logger、ChatGPTService 等已通过 public 访问级别自动导出
// 使用 `import Shared` 后可直接访问这些类型

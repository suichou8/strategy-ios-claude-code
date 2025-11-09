//
//  ChatGPTConfig.swift
//  Shared
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

// MARK: - AI Model Enum

/// AI 模型定义
public enum AIModel: String, CaseIterable, Sendable {
    // MARK: - Reasoning Models (深度推理模型)
    /// o3-pro: 最强推理模型（Pro 用户专属）
    case o3Pro = "o3-pro"

    /// o3: 深度推理模型（推荐！20%更少错误）
    case o3 = "o3"

    /// o4-mini: 高性价比推理模型
    case o4Mini = "o4-mini"

    /// o3-mini: 快速推理模型
    case o3Mini = "o3-mini"

    /// o1-preview: 旧版推理模型
    case o1Preview = "o1-preview"

    /// o1-mini: 旧版快速推理
    case o1Mini = "o1-mini"

    // MARK: - Fast Response Models (快速响应模型)
    /// gpt-5: 最新 GPT-5 模型
    case gpt5 = "gpt-5"

    /// gpt-5-mini: GPT-5 轻量版（推荐日常使用）
    case gpt5Mini = "gpt-5-mini"

    /// gpt-5-nano: GPT-5 超轻量版
    case gpt5Nano = "gpt-5-nano"

    /// gpt-4o: GPT-4 优化版
    case gpt4o = "gpt-4o"

    /// gpt-4o-mini: GPT-4o 轻量版
    case gpt4oMini = "gpt-4o-mini"

    // MARK: - Model Properties

    /// 是否是推理模型（需要使用 Responses API）
    public var isReasoningModel: Bool {
        switch self {
        case .o3Pro, .o3, .o4Mini, .o3Mini, .o1Preview, .o1Mini:
            return true
        case .gpt5, .gpt5Mini, .gpt5Nano:
            // GPT-5 系列实际上也是推理模型！
            return true
        default:
            return false
        }
    }

    /// 推荐的最大 completion/output tokens
    public var recommendedMaxTokens: Int {
        switch self {
        case .o3Pro, .o3, .o4Mini, .o3Mini, .o1Preview, .o1Mini:
            return 25000  // 推理模型支持长篇分析
        case .gpt5, .gpt5Mini, .gpt5Nano:
            return 10000  // GPT-5 系列也是推理模型，需要更多 tokens
        case .gpt4o, .gpt4oMini:
            return 2000   // GPT-4 系列
        }
    }

    /// 支持的温度参数（nil 表示不支持自定义）
    public var supportsTemperature: Bool {
        switch self {
        case .o3Pro, .o3, .o4Mini, .o3Mini, .o1Preview, .o1Mini:
            return false  // 推理模型固定温度为 1.0
        case .gpt5, .gpt5Mini, .gpt5Nano:
            return false  // GPT-5 固定温度为 1.0
        case .gpt4o, .gpt4oMini:
            return true   // GPT-4 支持 0.0-2.0
        }
    }

    /// 模型描述
    public var description: String {
        switch self {
        case .o3Pro:
            return "o3-pro: 最强推理模型（Pro 用户专属）"
        case .o3:
            return "o3: 深度推理，20% 更少错误"
        case .o4Mini:
            return "o4-mini: 高性价比推理"
        case .o3Mini:
            return "o3-mini: 快速推理"
        case .o1Preview:
            return "o1-preview: 旧版推理模型"
        case .o1Mini:
            return "o1-mini: 旧版快速推理"
        case .gpt5:
            return "gpt-5: 最新 GPT-5"
        case .gpt5Mini:
            return "gpt-5-mini: 日常分析（推荐）"
        case .gpt5Nano:
            return "gpt-5-nano: 超轻量"
        case .gpt4o:
            return "gpt-4o: GPT-4 优化版"
        case .gpt4oMini:
            return "gpt-4o-mini: GPT-4 轻量版"
        }
    }

    /// 使用场景建议
    public var useCase: String {
        switch self {
        case .o3Pro, .o3:
            return "复杂技术分析、多指标组合、风险评估"
        case .o4Mini, .o3Mini:
            return "中等复杂度分析、快速推理"
        case .o1Preview, .o1Mini:
            return "旧版推理，不推荐新项目使用"
        case .gpt5, .gpt5Mini, .gpt5Nano:
            return "日常查询、实时摘要、快速响应"
        case .gpt4o, .gpt4oMini:
            return "通用对话、标准分析"
        }
    }
}

// MARK: - ChatGPT Config

/// ChatGPT API 配置
public enum ChatGPTConfig {
    /// API Base URL (不包含具体endpoint，由服务层添加)
    public static let baseURL = "https://api.openai.com/v1"

    /// API Key (从 Secrets.swift 读取)
    ///
    /// ⚠️ 注意：Secrets.swift 文件包含 API Key，已添加到 .gitignore，不会被提交到 Git
//    public static let apiKey = Secrets.openAIAPIKey
    public static let apiKey = ""

    // MARK: - Current Model Configuration

    /// 当前使用的模型
    ///
    /// 切换方式：
    /// ```swift
    /// // 深度推理分析
    /// public static let currentModel: AIModel = .o3
    ///
    /// // 日常快速分析（测试/速率限制时使用）
    /// public static let currentModel: AIModel = .gpt5Mini
    /// ```
    public static let currentModel: AIModel = .gpt5Mini  // 临时测试，正式使用改为 .o3

    /// 模型字符串（从 currentModel 获取）
    public static var model: String {
        currentModel.rawValue
    }

    /// 最大 completion/output tokens（从 currentModel 获取推荐值）
    public static var maxCompletionTokens: Int {
        currentModel.recommendedMaxTokens
    }

    /// 温度参数 (控制创造性，0=确定性，1=平衡，2=随机性)
    /// 自动根据模型类型设置：
    /// - 推理模型和 GPT-5: nil (固定温度)
    /// - GPT-4: 0.7 (默认值)
    public static var temperature: Double? {
        currentModel.supportsTemperature ? 0.7 : nil
    }
}

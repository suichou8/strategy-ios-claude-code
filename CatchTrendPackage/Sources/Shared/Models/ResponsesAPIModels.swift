//
//  ResponsesAPIModels.swift
//  Shared
//
//  Created by Claude Code on 2025/10/13.
//

import Foundation

// MARK: - Responses API Request Models

/// Responses API 请求
public struct ResponsesRequest: Codable, Sendable {
    public let model: String
    public let input: String
    public let instructions: String?
    public let reasoning: ReasoningConfig?
    public let background: Bool?
    public let maxOutputTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case instructions
        case reasoning
        case background
        case maxOutputTokens = "max_output_tokens"
    }

    public init(
        model: String,
        input: String,
        instructions: String? = nil,
        reasoning: ReasoningConfig? = nil,
        background: Bool? = nil,
        maxOutputTokens: Int? = nil
    ) {
        self.model = model
        self.input = input
        self.instructions = instructions
        self.reasoning = reasoning
        self.background = background
        self.maxOutputTokens = maxOutputTokens
    }
}

/// 推理配置
public struct ReasoningConfig: Codable, Sendable {
    public let effort: String?
    public let summary: String?

    public init(effort: String? = nil, summary: String? = nil) {
        self.effort = effort
        self.summary = summary
    }

    /// 自动摘要配置
    public static let auto = ReasoningConfig(summary: "auto")

    /// 详细摘要配置
    public static let detailed = ReasoningConfig(summary: "detailed")

    /// 中等推理强度
    public static let mediumEffort = ReasoningConfig(effort: "medium", summary: "auto")

    /// 高推理强度
    public static let highEffort = ReasoningConfig(effort: "high", summary: "detailed")
}

// MARK: - Responses API Response Models

/// Responses API 响应
public struct ResponsesResponse: Codable, Sendable {
    public let id: String
    public let object: String
    public let createdAt: Int      // API 返回 "created_at" 而不是 "created"
    public let status: String?     // 响应状态（如 "completed"）
    public let model: String
    public let output: [ResponseOutput]
    public let usage: ResponseUsage?

    enum CodingKeys: String, CodingKey {
        case id, object, status, model, output, usage
        case createdAt = "created_at"
    }

    public init(
        id: String,
        object: String,
        createdAt: Int,
        status: String?,
        model: String,
        output: [ResponseOutput],
        usage: ResponseUsage?
    ) {
        self.id = id
        self.object = object
        self.createdAt = createdAt
        self.status = status
        self.model = model
        self.output = output
        self.usage = usage
    }
}

/// 响应输出项
public struct ResponseOutput: Codable, Sendable {
    public let id: String?          // output 的唯一 ID
    public let type: String
    public let status: String?      // message 类型才有（如 "completed"）
    public let content: [ContentItem]?
    public let summary: [String]?   // reasoning 类型才有
    public let role: String?        // message 类型才有（如 "assistant"）

    public init(
        id: String? = nil,
        type: String,
        status: String? = nil,
        content: [ContentItem]?,
        summary: [String]? = nil,
        role: String? = nil
    ) {
        self.id = id
        self.type = type
        self.status = status
        self.content = content
        self.summary = summary
        self.role = role
    }
}

/// 内容项
public struct ContentItem: Codable, Sendable {
    public let type: String
    public let text: String?
    public let annotations: [String]?   // API 返回的注释数组（通常为空）
    public let logprobs: [String]?      // API 返回的 logprobs（通常为空）

    public init(
        type: String,
        text: String?,
        annotations: [String]? = nil,
        logprobs: [String]? = nil
    ) {
        self.type = type
        self.text = text
        self.annotations = annotations
        self.logprobs = logprobs
    }
}

/// 使用统计
public struct ResponseUsage: Codable, Sendable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    public let completionTokensDetails: CompletionTokensDetails?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "input_tokens"           // ✅ Responses API 使用 input_tokens
        case completionTokens = "output_tokens"      // ✅ Responses API 使用 output_tokens
        case totalTokens = "total_tokens"
        case completionTokensDetails = "output_tokens_details"  // ✅ Responses API 使用 output_tokens_details
    }

    public init(
        promptTokens: Int,
        completionTokens: Int,
        totalTokens: Int,
        completionTokensDetails: CompletionTokensDetails?
    ) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
        self.completionTokensDetails = completionTokensDetails
    }
}

/// 完成 Token 详情
public struct CompletionTokensDetails: Codable, Sendable {
    public let reasoningTokens: Int?
    public let audioTokens: Int?

    enum CodingKeys: String, CodingKey {
        case reasoningTokens = "reasoning_tokens"
        case audioTokens = "audio_tokens"
    }

    public init(reasoningTokens: Int?, audioTokens: Int?) {
        self.reasoningTokens = reasoningTokens
        self.audioTokens = audioTokens
    }
}

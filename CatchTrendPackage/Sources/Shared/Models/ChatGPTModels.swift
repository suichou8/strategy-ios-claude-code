//
//  ChatGPTModels.swift
//  Shared
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

// MARK: - Request Models

/// ChatGPT 聊天完成请求
public struct ChatCompletionRequest: Codable, Sendable {
    public let model: String
    public let messages: [ChatMessage]
    public let temperature: Double?
    public let maxTokens: Int?
    public let maxCompletionTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case maxCompletionTokens = "max_completion_tokens"
    }

    public init(
        model: String,
        messages: [ChatMessage],
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        maxCompletionTokens: Int? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.maxCompletionTokens = maxCompletionTokens
    }
}

/// 聊天消息
public struct ChatMessage: Codable, Sendable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }

    /// 创建系统消息
    public static func system(_ content: String) -> ChatMessage {
        ChatMessage(role: "system", content: content)
    }

    /// 创建用户消息
    public static func user(_ content: String) -> ChatMessage {
        ChatMessage(role: "user", content: content)
    }

    /// 创建助手消息
    public static func assistant(_ content: String) -> ChatMessage {
        ChatMessage(role: "assistant", content: content)
    }
}

// MARK: - Response Models

/// ChatGPT 聊天完成响应
public struct ChatCompletionResponse: Codable, Sendable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [ChatChoice]
    public let usage: ChatUsage?

    public init(
        id: String,
        object: String,
        created: Int,
        model: String,
        choices: [ChatChoice],
        usage: ChatUsage?
    ) {
        self.id = id
        self.object = object
        self.created = created
        self.model = model
        self.choices = choices
        self.usage = usage
    }
}

/// 聊天选择
public struct ChatChoice: Codable, Sendable {
    public let index: Int
    public let message: ChatMessage
    public let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }

    public init(index: Int, message: ChatMessage, finishReason: String?) {
        self.index = index
        self.message = message
        self.finishReason = finishReason
    }
}

/// 使用统计
public struct ChatUsage: Codable, Sendable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }

    public init(promptTokens: Int, completionTokens: Int, totalTokens: Int) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

// MARK: - Error Models

/// ChatGPT 错误响应
public struct ChatGPTErrorResponse: Codable, Sendable {
    public let error: ChatGPTError

    public init(error: ChatGPTError) {
        self.error = error
    }
}

/// ChatGPT 错误详情
public struct ChatGPTError: Codable, Sendable {
    public let message: String
    public let type: String
    public let param: String?
    public let code: String?

    public init(message: String, type: String, param: String?, code: String?) {
        self.message = message
        self.type = type
        self.param = param
        self.code = code
    }
}

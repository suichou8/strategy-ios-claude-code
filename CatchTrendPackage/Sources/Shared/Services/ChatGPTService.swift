//
//  ChatGPTService.swift
//  Shared
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// ChatGPT 服务
public actor ChatGPTService {
    /// 单例
    public static let shared = ChatGPTService()

    /// URLSession（配置了更长的超时时间）
    private let session: URLSession

    /// Logger
    private let logger = Logger.Category.network

    /// 初始化
    private init() {
        // 创建自定义配置，设置更长的超时时间
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 90.0      // 请求超时：90秒
        config.timeoutIntervalForResource = 120.0    // 资源超时：120秒
        self.session = URLSession(configuration: config)
        logger.info("ChatGPTService 初始化（超时: 90s/120s）")
    }

    /// 发送聊天完成请求
    /// - Parameter request: 聊天完成请求
    /// - Returns: 聊天完成响应
    public func sendChatCompletion(
        _ request: ChatCompletionRequest
    ) async throws -> ChatCompletionResponse {
        let url = URL(string: "\(ChatGPTConfig.baseURL)/chat/completions")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(ChatGPTConfig.apiKey)", forHTTPHeaderField: "Authorization")

        // 编码请求体
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try encoder.encode(request)

        logger.debug("发送 ChatGPT 请求: model=\(request.model), messages=\(request.messages.count)")

        // 发起请求（带超时处理）
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as NSError {
            // 处理网络错误
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorTimedOut:
                    logger.error("ChatGPT 请求超时")
                    throw ChatGPTServiceError.timeout
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    logger.error("网络连接失败: \(error.localizedDescription)")
                    throw ChatGPTServiceError.networkError(error.localizedDescription)
                default:
                    logger.error("网络错误: \(error.localizedDescription)")
                    throw ChatGPTServiceError.networkError(error.localizedDescription)
                }
            }
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTServiceError.invalidResponse
        }

        logger.debug("ChatGPT 响应: \(httpResponse.statusCode)")

        // 处理响应
        switch httpResponse.statusCode {
        case 200...299:
            // 成功，解码响应
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // 先尝试记录原始响应以便调试
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("API 原始响应: \(jsonString.prefix(500))...")
            }

            do {
                let chatResponse = try decoder.decode(ChatCompletionResponse.self, from: data)

                if let usage = chatResponse.usage {
                    logger.debug("Tokens 使用: prompt=\(usage.promptTokens), completion=\(usage.completionTokens), total=\(usage.totalTokens)")
                }

                return chatResponse
            } catch {
                logger.error("解码响应失败: \(error)")
                logger.error("响应数据: \(String(data: data, encoding: .utf8) ?? "无法解析")")
                throw ChatGPTServiceError.apiError("解码响应失败: \(error.localizedDescription)")
            }

        case 401:
            logger.error("ChatGPT 认证失败")
            throw ChatGPTServiceError.unauthorized

        case 429:
            // 429 可能是 rate limit 或 insufficient quota
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let errorResponse = try? decoder.decode(ChatGPTErrorResponse.self, from: data) {
                // 检查是否是配额不足
                if errorResponse.error.code == "insufficient_quota" {
                    logger.error("ChatGPT 配额不足: \(errorResponse.error.message)")
                    throw ChatGPTServiceError.insufficientQuota
                } else {
                    logger.warning("ChatGPT 请求过于频繁: \(errorResponse.error.message)")
                    throw ChatGPTServiceError.rateLimited
                }
            } else {
                logger.warning("ChatGPT 请求过于频繁")
                throw ChatGPTServiceError.rateLimited
            }

        default:
            // 尝试解析错误响应
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let errorResponse = try? decoder.decode(ChatGPTErrorResponse.self, from: data) {
                logger.error("ChatGPT 错误: \(errorResponse.error.message)")
                throw ChatGPTServiceError.apiError(errorResponse.error.message)
            } else {
                logger.error("ChatGPT HTTP 错误: \(httpResponse.statusCode)")
                throw ChatGPTServiceError.httpError(statusCode: httpResponse.statusCode)
            }
        }
    }

    /// 简化的聊天方法
    /// - Parameters:
    ///   - systemPrompt: 系统提示
    ///   - userMessage: 用户消息
    /// - Returns: AI 回复内容
    public func chat(
        systemPrompt: String,
        userMessage: String
    ) async throws -> String {
        // o 系列推理模型 (o1/o3/o4) 不支持 system role
        // 需要将 system prompt 合并到 user message
        let isReasoningModel = ChatGPTConfig.model.hasPrefix("o1") ||
                              ChatGPTConfig.model.hasPrefix("o3") ||
                              ChatGPTConfig.model.hasPrefix("o4")

        let messages: [ChatMessage]
        if isReasoningModel {
            // 推理模型：将 system prompt 作为前缀添加到 user message
            let combinedMessage = "\(systemPrompt)\n\n\(userMessage)"
            messages = [.user(combinedMessage)]
            logger.debug("使用推理模型，合并 system prompt")
        } else {
            // 其他模型：使用标准的 system + user 格式
            messages = [
                .system(systemPrompt),
                .user(userMessage)
            ]
        }

        let request = ChatCompletionRequest(
            model: ChatGPTConfig.model,
            messages: messages,
            temperature: ChatGPTConfig.temperature,
            maxTokens: nil,
            maxCompletionTokens: ChatGPTConfig.maxCompletionTokens
        )

        let response = try await sendChatCompletion(request)

        guard let firstChoice = response.choices.first else {
            throw ChatGPTServiceError.emptyResponse
        }

        return firstChoice.message.content
    }
}

// MARK: - Errors

/// ChatGPT 服务错误
public enum ChatGPTServiceError: LocalizedError, Sendable {
    case invalidResponse
    case unauthorized
    case rateLimited
    case insufficientQuota
    case apiError(String)
    case httpError(statusCode: Int)
    case emptyResponse
    case timeout
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "无效的响应"
        case .unauthorized:
            return "认证失败，请检查 API Key"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .insufficientQuota:
            return "API 配额不足，请检查账户余额"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .httpError(let statusCode):
            return "HTTP 错误: \(statusCode)"
        case .emptyResponse:
            return "空响应"
        case .timeout:
            return "请求超时，请检查网络连接或稍后重试"
        case .networkError(let message):
            return "网络错误: \(message)"
        }
    }
}

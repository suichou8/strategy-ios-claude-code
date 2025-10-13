//
//  ResponsesAPIService.swift
//  Shared
//
//  Created by Claude Code on 2025/10/13.
//

import Foundation

/// Responses API 服务（用于 o3/o4 推理模型）
public actor ResponsesAPIService {
    /// 单例
    public static let shared = ResponsesAPIService()

    /// URLSession（配置了更长的超时时间，适合推理模型）
    private let session: URLSession

    /// Logger
    private let logger = Logger.Category.network

    /// 初始化
    private init() {
        // 创建自定义配置，推理模型需要更长的超时时间
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120.0     // 请求超时：120秒（推理模型更慢）
        config.timeoutIntervalForResource = 180.0    // 资源超时：180秒
        self.session = URLSession(configuration: config)
        logger.info("ResponsesAPIService 初始化（超时: 120s/180s）")
    }

    /// 发送 Responses API 请求
    /// - Parameter request: Responses 请求
    /// - Returns: Responses 响应
    public func sendResponse(
        _ request: ResponsesRequest
    ) async throws -> ResponsesResponse {
        let url = URL(string: "\(ChatGPTConfig.baseURL)/responses")!

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(ChatGPTConfig.apiKey)", forHTTPHeaderField: "Authorization")

        // 编码请求体
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        urlRequest.httpBody = try encoder.encode(request)

        logger.debug("发送 Responses API 请求: model=\(request.model)")

        // 发起请求（带超时处理）
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as NSError {
            // 处理网络错误
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorTimedOut:
                    logger.error("Responses API 请求超时")
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

        logger.debug("Responses API 响应: \(httpResponse.statusCode)")
        logger.debug("响应数据大小: \(data.count) 字节")

        // 打印完整的响应头用于调试
        logger.debug("响应头: \(httpResponse.allHeaderFields)")

        // 处理响应
        switch httpResponse.statusCode {
        case 200...299:
            // 先记录原始响应以便调试
            if let jsonString = String(data: data, encoding: .utf8) {
                logger.debug("API 原始响应 (前1000字符): \(jsonString.prefix(1000))...")
                logger.debug("原始响应总长度: \(jsonString.count) 字符")
            } else {
                logger.error("❌ 无法将响应数据转换为 UTF-8 字符串！数据可能已损坏或仍被压缩")
                logger.debug("响应数据的前100字节（十六进制）: \(data.prefix(100).map { String(format: "%02x", $0) }.joined(separator: " "))")
            }

            // 成功，解码响应
            let decoder = JSONDecoder()
            // 注意：不使用 convertFromSnakeCase，因为我们在 CodingKeys 中已经手动映射了所有字段
            // decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                let responsesResponse = try decoder.decode(ResponsesResponse.self, from: data)

                logger.debug("解码成功！output 数组长度: \(responsesResponse.output.count)")

                // 打印每个 output 的类型和内容
                for (index, output) in responsesResponse.output.enumerated() {
                    logger.debug("output[\(index)]: type=\(output.type)")
                    if output.type == "message" {
                        if let content = output.content {
                            logger.debug("  content 数组长度: \(content.count)")
                            for (contentIndex, item) in content.enumerated() {
                                logger.debug("  content[\(contentIndex)]: type=\(item.type), text长度=\(item.text?.count ?? 0)")
                            }
                        } else {
                            logger.warning("  content 为 nil！")
                        }
                    }
                }

                if let usage = responsesResponse.usage {
                    let reasoningTokens = usage.completionTokensDetails?.reasoningTokens ?? 0
                    logger.debug("Tokens 使用: prompt=\(usage.promptTokens), completion=\(usage.completionTokens) (reasoning=\(reasoningTokens)), total=\(usage.totalTokens)")
                }

                return responsesResponse
            } catch {
                logger.error("解码 ResponsesResponse 失败: \(error)")
                let dataString = String(data: data, encoding: .utf8) ?? "无法解析"
                logger.error("响应数据: \(dataString)")
                throw ChatGPTServiceError.apiError("解码响应失败: \(error.localizedDescription)")
            }

        case 401:
            logger.error("Responses API 认证失败")
            throw ChatGPTServiceError.unauthorized

        case 429:
            // 429 可能是 rate limit 或 insufficient quota
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let errorResponse = try? decoder.decode(ChatGPTErrorResponse.self, from: data) {
                // 检查是否是配额不足
                if errorResponse.error.code == "insufficient_quota" {
                    logger.error("Responses API 配额不足: \(errorResponse.error.message)")
                    throw ChatGPTServiceError.insufficientQuota
                } else {
                    logger.warning("Responses API 请求过于频繁: \(errorResponse.error.message)")
                    throw ChatGPTServiceError.rateLimited
                }
            } else {
                logger.warning("Responses API 请求过于频繁")
                throw ChatGPTServiceError.rateLimited
            }

        default:
            // 尝试解析错误响应
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let errorResponse = try? decoder.decode(ChatGPTErrorResponse.self, from: data) {
                logger.error("Responses API 错误: \(errorResponse.error.message)")
                throw ChatGPTServiceError.apiError(errorResponse.error.message)
            } else {
                logger.error("Responses API HTTP 错误: \(httpResponse.statusCode)")
                throw ChatGPTServiceError.httpError(statusCode: httpResponse.statusCode)
            }
        }
    }

    /// 简化的推理方法（用于 o3/o4 模型）
    /// - Parameters:
    ///   - instructions: 系统指令（类似 system prompt）
    ///   - input: 用户输入
    ///   - reasoning: 推理配置（可选，需要组织验证才能使用推理摘要）
    /// - Returns: AI 回复内容和推理摘要
    public func reasoning(
        instructions: String,
        input: String,
        reasoning: ReasoningConfig? = nil
    ) async throws -> (content: String, reasoningSummary: String?) {
        let request = ResponsesRequest(
            model: ChatGPTConfig.model,
            input: input,
            instructions: instructions,
            reasoning: reasoning,
            maxOutputTokens: ChatGPTConfig.maxCompletionTokens
        )

        let response = try await sendResponse(request)

        logger.debug("开始提取内容，output 数组长度: \(response.output.count)")

        // 提取内容：查找 type == "message" 的输出项
        var contentText = ""
        var reasoningSummaryText: String?

        for (index, output) in response.output.enumerated() {
            logger.debug("处理 output[\(index)]: type=\(output.type)")

            if output.type == "message", let content = output.content {
                logger.debug("  找到 message 类型，content 长度: \(content.count)")
                // 提取 message 类型的文本内容
                for (itemIndex, item) in content.enumerated() {
                    logger.debug("    处理 content[\(itemIndex)]: type=\(item.type)")
                    if item.type == "output_text", let text = item.text {
                        logger.debug("    找到 output_text，长度: \(text.count)")
                        contentText += text
                    }
                }
            } else if output.type == "reasoning", let summary = output.summary, !summary.isEmpty {
                // 提取推理摘要（如果有）
                reasoningSummaryText = summary.joined(separator: "\n")
                logger.debug("  找到推理摘要，长度: \(reasoningSummaryText!.count) 字符")
            }
        }

        logger.debug("内容提取完成，总长度: \(contentText.count) 字符")

        // 确保至少有内容
        guard !contentText.isEmpty else {
            logger.error("内容为空！抛出 emptyResponse 错误")
            throw ChatGPTServiceError.emptyResponse
        }

        logger.debug("返回内容，长度: \(contentText.count) 字符")
        return (contentText, reasoningSummaryText)
    }
}

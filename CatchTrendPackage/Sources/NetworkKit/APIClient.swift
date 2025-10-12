//
//  APIClient.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation

/// API 客户端
public actor APIClient {
    /// Base URL
    private let baseURL: String

    /// URLSession
    private let session: URLSession

    /// 认证管理器
    private let authManager: AuthManager

    /// 初始化
    /// - Parameters:
    ///   - baseURL: API Base URL，默认从 Bundle 读取
    ///   - session: URLSession，默认使用 .shared
    ///   - authManager: 认证管理器
    public init(
        baseURL: String? = nil,
        session: URLSession = .shared,
        authManager: AuthManager
    ) {
        // 优先使用传入的 baseURL，否则使用配置
        if let baseURL = baseURL {
            self.baseURL = baseURL
        } else {
            // 使用 APIConfig 中的配置
            self.baseURL = APIConfig.baseURL
        }

        self.session = session
        self.authManager = authManager

        if APIConfig.enableLogging {
            print("🔧 APIClient 初始化: baseURL=\(self.baseURL)")
        }
    }

    /// 发起请求
    /// - Parameters:
    ///   - endpoint: API 端点
    ///   - responseType: 响应数据类型
    /// - Returns: 解码后的响应数据
    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type = T.self
    ) async throws -> T {
        // 1. 构建 URL
        guard let url = buildURL(for: endpoint) else {
            if APIConfig.enableLogging {
                print("❌ 无效的 URL: baseURL=\(baseURL), path=\(endpoint.path)")
            }
            throw NetworkError.invalidURL
        }

        if APIConfig.enableLogging {
            print("🌐 API 请求: \(endpoint.method.rawValue) \(url.absoluteString)")
        }

        // 2. 构建 URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 3. 添加认证 Token（如果需要）
        if endpoint.requiresAuth {
            let token = await MainActor.run {
                authManager.getAccessToken()
            }
            guard let token = token else {
                throw NetworkError.unauthorized
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 4. 添加请求体（如果有）
        if let body = endpoint.body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        // 5. 发起请求
        let (data, response) = try await session.data(for: request)

        // 6. 验证响应
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        // 7. 处理 HTTP 状态码
        if APIConfig.enableLogging {
            print("📡 HTTP 响应: \(httpResponse.statusCode)")
        }

        switch httpResponse.statusCode {
        case 200...299:
            // 成功，继续解码
            break
        case 401:
            if APIConfig.enableLogging {
                print("❌ HTTP 401: 未授权")
            }
            throw NetworkError.unauthorized
        case 429:
            if APIConfig.enableLogging {
                print("❌ HTTP 429: 请求过于频繁")
            }
            throw NetworkError.rateLimited
        case 500...599:
            if APIConfig.enableLogging {
                print("❌ HTTP \(httpResponse.statusCode): 服务器错误")
            }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            if APIConfig.enableLogging {
                print("❌ HTTP \(httpResponse.statusCode): HTTP 错误")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("响应内容: \(responseString)")
                }
            }
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        // 8. 解码响应数据
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    /// 构建完整 URL
    /// - Parameter endpoint: API 端点
    /// - Returns: 完整 URL
    private func buildURL(for endpoint: APIEndpoint) -> URL? {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            return nil
        }

        // 添加查询参数
        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url
    }
}

// MARK: - Convenience Methods

extension APIClient {
    /// 登录
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    /// - Returns: 登录响应
    public func login(username: String, password: String) async throws -> LoginResponse {
        let response = try await request(
            .login(username: username, password: password),
            responseType: LoginResponse.self
        )

        // 登录成功后保存 Token
        if response.success {
            let token = response.accessToken
            try await MainActor.run {
                try authManager.saveAuth(token: token, username: username)
            }
        }

        return response
    }

    /// 获取综合数据
    /// - Parameters:
    ///   - symbol: 股票代码
    ///   - timestamp: 时间戳（可选）
    /// - Returns: 综合数据响应
    public func getComprehensiveData(
        symbol: String,
        timestamp: Int? = nil
    ) async throws -> ComprehensiveResponse {
        return try await request(
            .comprehensive(symbol: symbol, timestamp: timestamp),
            responseType: ComprehensiveResponse.self
        )
    }
}

// MARK: - Response Models

/// 登录响应
public struct LoginResponse: Decodable, Sendable {
    public let success: Bool
    public let message: String
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int

    public init(success: Bool, message: String, accessToken: String, tokenType: String, expiresIn: Int) {
        self.success = success
        self.message = message
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
    }
}

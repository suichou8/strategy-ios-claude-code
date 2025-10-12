//
//  AuthManager.swift
//  NetworkKit
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation
import Security
import Observation

/// JWT 认证管理器
@Observable
@MainActor
public final class AuthManager {
    /// 单例
    public static let shared = AuthManager()

    /// 是否已认证
    public private(set) var isAuthenticated: Bool = false

    /// 当前用户名
    public private(set) var currentUsername: String?

    /// Keychain 服务名称
    private let service = "com.sunshinenew07.CatchTrend"

    /// Token 存储 key
    private let tokenKey = "jwt_access_token"

    /// 用户名存储 key
    private let usernameKey = "username"

    private init() {
        checkAuthStatus()
    }

    /// 保存认证信息
    public func saveAuth(token: String, username: String) throws {
        // 保存 Token
        try saveToKeychain(value: token, forKey: tokenKey)

        // 保存用户名
        try saveToKeychain(value: username, forKey: usernameKey)

        // 更新状态
        isAuthenticated = true
        currentUsername = username
    }

    /// 获取访问令牌
    public func getAccessToken() -> String? {
        return try? loadFromKeychain(forKey: tokenKey)
    }

    /// 清除认证信息
    public func clearAuth() {
        deleteFromKeychain(forKey: tokenKey)
        deleteFromKeychain(forKey: usernameKey)

        isAuthenticated = false
        currentUsername = nil
    }

    /// 检查认证状态
    private func checkAuthStatus() {
        if let token = try? loadFromKeychain(forKey: tokenKey),
           !token.isEmpty,
           let username = try? loadFromKeychain(forKey: usernameKey) {
            isAuthenticated = true
            currentUsername = username
        } else {
            isAuthenticated = false
            currentUsername = nil
        }
    }

    // MARK: - Keychain Operations

    /// 保存到 Keychain
    private func saveToKeychain(value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw NetworkError.encodingError(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法编码字符串"]))
        }

        // 先删除已存在的项
        deleteFromKeychain(forKey: key)

        // 构建查询字典
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // 添加到 Keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw NetworkError.unknown(NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "无法保存到 Keychain"]))
        }
    }

    /// 从 Keychain 读取
    private func loadFromKeychain(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw NetworkError.unknown(NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: "无法从 Keychain 读取"]))
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingError(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解码数据"]))
        }

        return string
    }

    /// 从 Keychain 删除
    private func deleteFromKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

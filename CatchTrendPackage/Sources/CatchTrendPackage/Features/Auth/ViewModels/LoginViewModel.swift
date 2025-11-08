//
//  LoginViewModel.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation
import Observation
import NetworkKit
import Shared

/// 登录视图模型
/// 负责处理登录业务逻辑和状态管理
@MainActor
@Observable
public final class LoginViewModel {
    // MARK: - Published State

    /// 用户名
    var username: String = ""

    /// 密码
    var password: String = ""

    /// 是否正在加载
    var isLoading: Bool = false

    /// 错误信息
    var errorMessage: String?

    /// 是否显示错误提示
    var showError: Bool = false

    // MARK: - Dependencies

    private let authManager: AuthManager
    private let apiClient: APIClient
    private let logger = Logger.Category.auth

    // MARK: - Initialization

    public init(authManager: AuthManager, apiClient: APIClient) {
        self.authManager = authManager
        self.apiClient = apiClient
    }

    // MARK: - Computed Properties

    /// 登录按钮是否可用
    var isLoginButtonEnabled: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }

    // MARK: - Actions

    /// 处理登录
    func login() async {
        guard !username.isEmpty && !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        showError = false

        logger.info("开始登录: username=\(username)")

        do {
            let response = try await apiClient.login(
                username: username,
                password: password
            )

            isLoading = false

            // 登录成功，AuthManager 已自动更新状态
            // API 成功返回即表示登录成功，失败会在 catch 块中处理
            logSuccess(response: response)
        } catch let error as NetworkError {
            isLoading = false
            logger.error("网络错误", error: error)
            handleNetworkError(error)
        } catch {
            isLoading = false
            logger.error("未知错误", error: error)
            handleUnknownError(error)
        }
    }

    /// 清除错误
    func clearError() {
        errorMessage = nil
        showError = false
    }

    // MARK: - Private Helpers

    private func logSuccess(response: LoginResponse) {
        logger.info("登录成功: \(response.message ?? "成功")")
        logger.debug("Token: \(response.accessToken.prefix(20))...")
        logger.debug("isAuthenticated: \(authManager.isAuthenticated)")
        logger.debug("currentUsername: \(authManager.currentUsername ?? "nil")")
    }

    private func handleLoginFailure(message: String) {
        errorMessage = message
        showError = true
    }

    private func handleNetworkError(_ error: NetworkError) {
        errorMessage = error.localizedDescription
        showError = true
    }

    private func handleUnknownError(_ error: Error) {
        errorMessage = "网络错误: \(error.localizedDescription)"
        showError = true
    }
}

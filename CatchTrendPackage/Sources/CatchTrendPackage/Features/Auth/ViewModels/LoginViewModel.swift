//
//  LoginViewModel.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import Foundation
import Observation
import NetworkKit

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

        #if DEBUG
        print("🔐 开始登录: username=\(username)")
        #endif

        do {
            let response = try await apiClient.login(
                username: username,
                password: password
            )

            isLoading = false

            if response.success {
                // 登录成功，AuthManager 已自动更新状态
                logSuccess(response: response)
            } else {
                // 登录失败（服务端返回失败）
                #if DEBUG
                print("❌ 登录失败: \(response.message)")
                #endif
                handleLoginFailure(message: response.message)
            }
        } catch let error as NetworkError {
            isLoading = false
            #if DEBUG
            print("❌ 网络错误: \(error.localizedDescription)")
            #endif
            handleNetworkError(error)
        } catch {
            isLoading = false
            #if DEBUG
            print("❌ 未知错误: \(error.localizedDescription)")
            #endif
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
        print("✅ 登录成功: \(response.message)")
        print("✅ Token: \(response.accessToken.prefix(20))...")
        print("✅ isAuthenticated: \(authManager.isAuthenticated)")
        print("✅ currentUsername: \(authManager.currentUsername ?? "nil")")
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

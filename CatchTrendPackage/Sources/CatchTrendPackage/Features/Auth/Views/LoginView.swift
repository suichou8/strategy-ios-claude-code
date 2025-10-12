//
//  LoginView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI
import NetworkKit

/// 登录页面主视图
/// 采用 MVVM 架构，视图层只负责 UI 布局和用户交互
public struct LoginView: View {
    @State private var viewModel: LoginViewModel

    // MARK: - Initialization

    public init(authManager: AuthManager, apiClient: APIClient) {
        self._viewModel = State(wrappedValue: LoginViewModel(
            authManager: authManager,
            apiClient: apiClient
        ))
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo
                LoginLogoView()

                // 登录表单
                LoginFormView(
                    username: $viewModel.username,
                    password: $viewModel.password
                )

                // 登录按钮
                LoginButton(
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.isLoginButtonEnabled,
                    action: { Task { await viewModel.login() } }
                )

                Spacer()
            }
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
            .alert("登录失败", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(
        authManager: .shared,
        apiClient: APIClient(authManager: .shared)
    )
}

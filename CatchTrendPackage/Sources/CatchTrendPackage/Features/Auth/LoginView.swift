//
//  LoginView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI
import NetworkKit

public struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false

    let authManager: AuthManager
    let apiClient: APIClient

    public init(authManager: AuthManager, apiClient: APIClient) {
        self.authManager = authManager
        self.apiClient = apiClient
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo 区域
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("CatchTrend")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("股票策略分析")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // 登录表单
                VStack(spacing: 16) {
                    // 用户名输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("用户名")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextField("请输入用户名", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    // 密码输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("密码")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        SecureField("请输入密码", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }

                    // 提示信息
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.caption)
                        Text("测试账号: sui / sui0617")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 32)

                // 登录按钮
                Button(action: handleLogin) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("登录")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(loginButtonEnabled ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .disabled(!loginButtonEnabled || isLoading)
                .padding(.horizontal, 32)
                .padding(.top, 8)

                Spacer()
            }
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
            .alert("登录失败", isPresented: $showError) {
                Button("确定", role: .cancel) {
                    showError = false
                }
            } message: {
                Text(errorMessage ?? "未知错误")
            }
        }
    }

    // MARK: - Computed Properties

    private var loginButtonEnabled: Bool {
        !username.isEmpty && !password.isEmpty
    }

    // MARK: - Actions

    private func handleLogin() {
        guard !username.isEmpty && !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // 调用登录 API
                let response = try await apiClient.login(
                    username: username,
                    password: password
                )

                await MainActor.run {
                    isLoading = false

                    if response.success {
                        // 登录成功，AuthManager 已自动更新状态
                        print("✅ 登录成功: \(response.message)")
                        print("✅ Token: \(response.accessToken.prefix(20))...")
                        print("✅ isAuthenticated: \(authManager.isAuthenticated)")
                        print("✅ currentUsername: \(authManager.currentUsername ?? "nil")")
                    } else {
                        // 登录失败
                        errorMessage = response.message
                        showError = true
                    }
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "网络错误: \(error.localizedDescription)"
                    showError = true
                }
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

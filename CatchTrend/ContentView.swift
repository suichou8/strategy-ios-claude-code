//
//  ContentView.swift
//  CatchTrend
//
//  Created by shuai zhang on 2025/10/12.
//

import SwiftUI
import CatchTrendPackage

/// 应用的根视图，根据认证状态显示登录页或主页
struct ContentView: View {
    let authManager: AuthManager
    let apiClient: APIClient

    var body: some View {
        // 根据认证状态显示不同的视图
        // AuthManager 使用 @Observable，状态变化会自动触发视图更新
        if authManager.isAuthenticated {
            // 已登录 - 显示主页
            HomeView(
                authManager: authManager,
                apiClient: apiClient
            )
        } else {
            // 未登录 - 显示登录页
            LoginView(
                authManager: authManager,
                apiClient: apiClient
            )
        }
    }
}

#Preview("已登录状态") {
    let authManager = AuthManager.shared
    // 模拟已登录状态（仅用于预览）
    ContentView(
        authManager: authManager,
        apiClient: APIClient(authManager: authManager)
    )
}

#Preview("未登录状态") {
    ContentView(
        authManager: .shared,
        apiClient: APIClient(authManager: .shared)
    )
}

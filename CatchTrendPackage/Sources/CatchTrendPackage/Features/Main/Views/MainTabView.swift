//
//  MainTabView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI
import NetworkKit

/// 主 Tab 视图
/// 登录后的主界面，包含多个功能模块
public struct MainTabView: View {
    let authManager: AuthManager
    let apiClient: APIClient

    @State private var selectedTab = 0

    public init(authManager: AuthManager, apiClient: APIClient) {
        self.authManager = authManager
        self.apiClient = apiClient
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            // CONL 分析页
            ConlAnalysisView(
                authManager: authManager,
                apiClient: apiClient
            )
            .tabItem {
                Label("CONL", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(0)

            // TSLL 分析页
            TsllAnalysisView(
                authManager: authManager,
                apiClient: apiClient
            )
            .tabItem {
                Label("TSLL", systemImage: "bolt.fill")
            }
            .tag(1)

            // SOXL 分析页
            SoxlAnalysisView(
                authManager: authManager,
                apiClient: apiClient
            )
            .tabItem {
                Label("SOXL", systemImage: "cpu.fill")
            }
            .tag(2)

            // 螺纹页（占位）
            RebarPlaceholderView()
                .tabItem {
                    Label("螺纹", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView(
        authManager: .shared,
        apiClient: APIClient(authManager: .shared)
    )
}

//
//  HomeView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI
import NetworkKit

public struct HomeView: View {
    let authManager: AuthManager

    public init(authManager: AuthManager) {
        self.authManager = authManager
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 欢迎信息
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)

                    Text("登录成功")
                        .font(.title)
                        .fontWeight(.bold)

                    if let username = authManager.currentUsername {
                        Text("欢迎回来, \(username)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 60)

                Spacer()

                // 占位内容
                VStack(spacing: 12) {
                    Label("实时行情", systemImage: "chart.line.uptrend.xyaxis")
                    Label("K线分析", systemImage: "chart.bar.fill")
                    Label("分时数据", systemImage: "waveform.path.ecg")
                }
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)

                Spacer()

                // 登出按钮
                Button(action: handleLogout) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("登出")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationTitle("CatchTrend")
        }
    }

    // MARK: - Actions

    private func handleLogout() {
        authManager.clearAuth()
        print("✅ 已登出")
        print("✅ isAuthenticated: \(authManager.isAuthenticated)")
    }
}

// MARK: - Preview

#Preview {
    HomeView(authManager: .shared)
}

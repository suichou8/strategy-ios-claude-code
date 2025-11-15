//
//  LoginButton.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI

/// 登录按钮组件
struct LoginButton: View {
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    // 计算视觉上是否应该显示为"启用"状态
    // loading 时也显示为启用状态，保持蓝色
    private var visuallyEnabled: Bool {
        isEnabled || isLoading
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("登录")
                        .font(.body)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Group {
                    if visuallyEnabled {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color(.systemGray5)
                    }
                }
            )
            .foregroundStyle(visuallyEnabled ? .white : Color(.systemGray3))
            .cornerRadius(14)
            .shadow(
                color: visuallyEnabled ? Color.blue.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(!isEnabled || isLoading)
        .padding(.horizontal, 32)
        .padding(.top, 12)
    }
}

// MARK: - Preview

#Preview("Enabled") {
    VStack(spacing: 20) {
        LoginButton(
            isLoading: false,
            isEnabled: true,
            action: {}
        )

        LoginButton(
            isLoading: true,
            isEnabled: true,
            action: {}
        )

        LoginButton(
            isLoading: false,
            isEnabled: false,
            action: {}
        )
    }
    .padding()
}

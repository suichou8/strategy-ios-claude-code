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

    var body: some View {
        Button(action: action) {
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
            .background(isEnabled ? Color.blue : Color.gray)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 32)
        .padding(.top, 8)
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

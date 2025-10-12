//
//  LoginFormView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI

/// 登录表单组件
struct LoginFormView: View {
    @Binding var username: String
    @Binding var password: String

    var body: some View {
        VStack(spacing: 16) {
            // 用户名输入
            FormFieldView(
                label: "用户名",
                placeholder: "请输入用户名"
            ) {
                TextField("请输入用户名", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            // 密码输入
            FormFieldView(
                label: "密码",
                placeholder: "请输入密码"
            ) {
                SecureField("请输入密码", text: $password)
                    .textFieldStyle(.roundedBorder)
            }

            // 提示信息
            HintView(
                icon: "info.circle",
                message: "测试账号: sui / sui0617"
            )
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Sub Components

/// 表单字段视图
private struct FormFieldView<Content: View>: View {
    let label: String
    let placeholder: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            content()
        }
    }
}

/// 提示信息视图
private struct HintView: View {
    let icon: String
    let message: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
            Text(message)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    LoginFormView(
        username: .constant(""),
        password: .constant("")
    )
}

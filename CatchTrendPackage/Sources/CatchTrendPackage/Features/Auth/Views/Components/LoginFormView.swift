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
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(spacing: 20) {
            // 用户名输入
            FormFieldView(
                label: "用户名",
                placeholder: "请输入用户名"
            ) {
                TextField("请输入用户名", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            // 密码输入
            FormFieldView(
                label: "密码",
                placeholder: "请输入密码"
            ) {
                HStack(spacing: 0) {
                    Group {
                        if isPasswordVisible {
                            TextField("请输入密码", text: $password)
                        } else {
                            SecureField("请输入密码", text: $password)
                        }
                    }
                    .font(.body)
                    .padding(.leading, 16)
                    .padding(.vertical, 14)

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 8)
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
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

// MARK: - Preview

#Preview {
    LoginFormView(
        username: .constant(""),
        password: .constant("")
    )
}

//
//  LoginLogoView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI

/// 登录页面 Logo 组件
struct LoginLogoView: View {
    var body: some View {
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
    }
}

#Preview {
    LoginLogoView()
}

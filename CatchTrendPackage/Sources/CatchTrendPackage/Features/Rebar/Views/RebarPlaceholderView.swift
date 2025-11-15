//
//  RebarPlaceholderView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI

/// 螺纹功能占位视图
/// 暂时占位，等待后续实现
public struct RebarPlaceholderView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.3))

                Text("螺纹")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("功能开发中...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("螺纹")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RebarPlaceholderView()
}

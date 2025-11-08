//
//  AnalysisSectionCard.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/11/09.
//

import SwiftUI

/// 分析报告章节卡片组件
/// 用于展示分析报告的各个部分（技术分析、趋势判断等）
struct AnalysisSectionCard: View {
    let icon: String
    let title: String
    let content: String
    var color: Color = .blue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Divider()

            // 内容
            Text(content)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        AnalysisSectionCard(
            icon: "chart.line.uptrend.xyaxis",
            title: "技术分析",
            content: "当前价格位于日内区间的上半部分，相对开盘价上涨2.5%，整体呈现上升趋势。VWAP显示买盘力量较强。",
            color: .blue
        )

        AnalysisSectionCard(
            icon: "arrow.up.right",
            title: "趋势判断",
            content: "短期趋势向上，5日均线呈多头排列，量价配合良好，上涨动能充足。",
            color: .green
        )

        AnalysisSectionCard(
            icon: "exclamationmark.triangle",
            title: "风险评估",
            content: "需要注意盘后跳空风险，建议控制仓位在20-30%以内，严格执行止损策略。",
            color: .orange
        )
    }
    .padding()
}

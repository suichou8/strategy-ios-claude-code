//
//  RiskMetricsCard.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/11/09.
//

import SwiftUI

/// 风险指标卡片组件
/// 展示 ATR、R/R 比率、波动率等风险相关指标
struct RiskMetricsCard: View {
    let atr: Double?
    let riskRewardRatio: Double?
    let volatility: Double?
    let positionSize: String?
    let accountRisk: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)

                Text("风险指标")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Divider()

            // 指标网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                // ATR
                if let atr = atr {
                    MetricItem(
                        icon: "chart.bar.fill",
                        label: "ATR(14)",
                        value: "$\(String(format: "%.2f", atr))",
                        color: .blue
                    )
                }

                // R/R 比率
                if let rr = riskRewardRatio {
                    MetricItem(
                        icon: "scalemass.fill",
                        label: "R/R 比率",
                        value: String(format: "1:%.1f", rr),
                        color: rr >= 1.8 ? .green : .orange,
                        badge: rr >= 1.8 ? "✅" : nil
                    )
                }

                // 波动率
                if let vol = volatility {
                    MetricItem(
                        icon: "waveform.path.ecg",
                        label: "波动率",
                        value: String(format: "%.1f%%", vol),
                        color: vol > 30 ? .red : .green
                    )
                }

                // 账户风险
                if let risk = accountRisk {
                    MetricItem(
                        icon: "percent",
                        label: "账户风险",
                        value: risk,
                        color: .orange
                    )
                }
            }

            // 仓位建议
            if let position = positionSize {
                VStack(alignment: .leading, spacing: 4) {
                    Text("建议仓位")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(position)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.orange.opacity(0.1))
                        .cornerRadius(6)
                }
            }

            // 风险提示
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("风险提示")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)

                    Text("CONL 为 2x 杠杆产品，日内复位会产生复利效应，震荡行情下存在收益衰减风险。建议严格控制仓位，避免隔夜持仓。")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }
            }
            .padding(8)
            .background(.orange.opacity(0.05))
            .cornerRadius(6)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

/// 指标项组件
private struct MetricItem: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = .primary
    var badge: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图标和标签
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color.opacity(0.7))

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 数值
            HStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(color)

                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        RiskMetricsCard(
            atr: 4.25,
            riskRewardRatio: 2.3,
            volatility: 28.5,
            positionSize: "20-30% (杠杆产品减半原则)",
            accountRisk: "0.5-0.75%"
        )

        RiskMetricsCard(
            atr: 5.80,
            riskRewardRatio: 1.5,
            volatility: 42.0,
            positionSize: "≤ 20% (高波动降低仓位)",
            accountRisk: "0.25%"
        )
    }
    .padding()
}

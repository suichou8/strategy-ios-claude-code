//
//  SupportResistanceView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/11/09.
//

import SwiftUI

/// 支撑位/压力位展示组件
/// 用于可视化显示关键价格水平
struct SupportResistanceView: View {
    let currentPrice: Double
    let supports: [PriceLevel]
    let resistances: [PriceLevel]

    struct PriceLevel: Identifiable {
        let id = UUID()
        let price: Double
        let label: String
        let description: String?
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title3)
                    .foregroundStyle(.purple)

                Text("关键价格水平")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Divider()

            // 压力位
            if !resistances.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("压力位", systemImage: "arrow.up.to.line")
                        .font(.subheadline)
                        .foregroundStyle(.red)

                    ForEach(resistances) { level in
                        PriceLevelRow(
                            level: level,
                            currentPrice: currentPrice,
                            isSupport: false
                        )
                    }
                }
            }

            // 当前价格
            HStack {
                Text("当前价格")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("$\(String(format: "%.2f", currentPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.blue.opacity(0.1))
            .cornerRadius(8)

            // 支撑位
            if !supports.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("支撑位", systemImage: "arrow.down.to.line")
                        .font(.subheadline)
                        .foregroundStyle(.green)

                    ForEach(supports) { level in
                        PriceLevelRow(
                            level: level,
                            currentPrice: currentPrice,
                            isSupport: true
                        )
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

/// 价格水平行组件
private struct PriceLevelRow: View {
    let level: SupportResistanceView.PriceLevel
    let currentPrice: Double
    let isSupport: Bool

    private var distance: Double {
        abs(level.price - currentPrice)
    }

    private var distancePercent: Double {
        currentPrice > 0 ? (distance / currentPrice) * 100 : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 标签
                Text(level.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // 价格
                Text("$\(String(format: "%.2f", level.price))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSupport ? .green : .red)

                // 距离
                Text("(\(String(format: "%.1f%%", distancePercent)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 描述
            if let description = level.description {
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background((isSupport ? Color.green : Color.red).opacity(0.05))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    SupportResistanceView(
        currentPrice: 125.50,
        supports: [
            .init(price: 123.20, label: "S1", description: "昨日低点"),
            .init(price: 121.80, label: "S2", description: "5日均线支撑"),
            .init(price: 119.50, label: "S3", description: "前期重要支撑位")
        ],
        resistances: [
            .init(price: 126.80, label: "R1", description: "昨日高点"),
            .init(price: 128.50, label: "R2", description: "近5日波峰"),
            .init(price: 131.20, label: "R3", description: "斐波那契61.8%回撤位")
        ]
    )
    .padding()
}

//
//  TradingSignalCard.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/11/09.
//

import SwiftUI

/// 交易信号卡片组件
/// 显示入场、止损、目标价等交易信号
struct TradingSignalCard: View {
    let signalType: SignalType
    let entryPrice: Double?
    let stopLoss: Double?
    let target1: Double?
    let target2: Double?
    let condition: String

    enum SignalType {
        case breakout
        case pullback

        var title: String {
            switch self {
            case .breakout: return "突破策略"
            case .pullback: return "回踩策略"
            }
        }

        var icon: String {
            switch self {
            case .breakout: return "arrow.up.circle.fill"
            case .pullback: return "arrow.turn.down.right"
            }
        }

        var color: Color {
            switch self {
            case .breakout: return .green
            case .pullback: return .blue
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: signalType.icon)
                    .font(.title3)
                    .foregroundStyle(signalType.color)

                Text(signalType.title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Divider()

            // 价格信息
            VStack(alignment: .leading, spacing: 12) {
                if let entry = entryPrice {
                    PriceRow(label: "入场价", price: entry, color: .blue)
                }

                if let stop = stopLoss {
                    PriceRow(label: "止损价", price: stop, color: .red)
                }

                if let t1 = target1 {
                    PriceRow(label: "目标一", price: t1, color: .green)
                }

                if let t2 = target2 {
                    PriceRow(label: "目标二", price: t2, color: .green)
                }
            }

            // 触发条件
            VStack(alignment: .leading, spacing: 4) {
                Text("触发条件")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(condition)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(signalType.color.opacity(0.1))
                    .cornerRadius(6)
            }

            // 风险回报比
            if let entry = entryPrice,
               let stop = stopLoss,
               let target = target1 {
                let risk = abs(entry - stop)
                let reward = abs(target - entry)
                let ratio = risk > 0 ? reward / risk : 0

                HStack {
                    Text("R/R 比率:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(String(format: "1:%.1f", ratio))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(ratio >= 1.8 ? .green : .orange)

                    if ratio >= 1.8 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(signalType.color.opacity(0.3), lineWidth: 1)
        )
    }
}

/// 价格行组件
private struct PriceRow: View {
    let label: String
    let price: Double
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text("$\(String(format: "%.2f", price))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        TradingSignalCard(
            signalType: .breakout,
            entryPrice: 125.50,
            stopLoss: 123.20,
            target1: 128.80,
            target2: 131.50,
            condition: "价格突破昨日高点 $124.80 且成交量放大1.2倍以上"
        )

        TradingSignalCard(
            signalType: .pullback,
            entryPrice: 122.30,
            stopLoss: 120.50,
            target1: 125.80,
            target2: 128.00,
            condition: "回踩VWAP $122.50附近出现反弹且5分钟K线收阳"
        )
    }
    .padding()
}

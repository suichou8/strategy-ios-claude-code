//
//  TsllAnalysisView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/11/09.
//

import SwiftUI
import NetworkKit
import Shared

public struct TsllAnalysisView: View {
    @State private var viewModel: TsllAnalysisViewModel

    public init(authManager: AuthManager, apiClient: APIClient) {
        self._viewModel = State(wrappedValue: TsllAnalysisViewModel(
            authManager: authManager,
            apiClient: apiClient
        ))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // 统一的柔和背景色
                Color(red: 0.96, green: 0.96, blue: 0.96)
                    .ignoresSafeArea()

                if viewModel.isLoadingAnalysis {
                    // 加载状态
                    loadingView
                } else if let analysis = viewModel.analysisData {
                    // 显示分析报告
                    analysisContent(analysis: analysis)
                } else {
                    // 空状态
                    emptyStateView
                }
            }
            .navigationTitle("TSLL 分析报告")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await viewModel.refreshAnalysis()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoadingAnalysis)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("登出") {
                        viewModel.logout()
                    }
                }
            }
            .refreshable {
                await viewModel.refreshAnalysis()
            }
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "未知错误")
            }
        }
    }

    // MARK: - View Components

    /// 加载视图
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("正在加载 TSLL 分析数据...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// 分析内容视图
    private func analysisContent(analysis: ConlAnalysisResponse) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // 交易摘要卡片（包含日期）
                tradingSummaryCard(summary: analysis.summary, date: analysis.date)
                    .padding(.top, 8)

                // 分时叙述卡片
                if let narrative = analysis.narrative {
                    narrativeCard(narrative: narrative)
                }

                // 交易单元列表
                if let units = analysis.units, !units.isEmpty {
                    tradingUnitsCard(units: units)
                }

                // AI 深度分析功能（已注释）
                // aiAnalysisButton

                // AI 分析结果（已注释）
                // if let aiAnalysis = viewModel.aiAnalysisResult {
                //     aiAnalysisResultCard(analysis: aiAnalysis)
                // } else if viewModel.isAIAnalyzing {
                //     aiAnalyzingView
                // }

                Spacer(minLength: 60)
            }
            .padding()
        }
    }

    /// 交易摘要卡片
    private func tradingSummaryCard(summary: TradingSummary, date: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和日期
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)

                Text("交易摘要")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                // 分析日期
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            // 价格区间
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("昨收")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(String(format: "%.2f", summary.prevClose))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 4) {
                    Text("开盘")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(String(format: "%.2f", summary.open))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 4) {
                    Text("最高")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(String(format: "%.2f", summary.dayHigh))")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }

                VStack(spacing: 4) {
                    Text("收盘")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("$\(String(format: "%.2f", summary.close))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)

            Divider()

            // 涨跌幅信息
            VStack(spacing: 12) {
                HStack {
                    Label("收盘涨跌幅", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%+.2f%%", summary.closeChangePct))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(summary.closeChangePct >= 0 ? .red : .green)
                }
                .padding()
                .background((summary.closeChangePct >= 0 ? Color.red : Color.green).opacity(0.1))
                .cornerRadius(8)

                HStack {
                    Label("开盘跳空", systemImage: "arrow.up.arrow.down")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%+.2f%%", summary.gapOpenPct))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(summary.gapOpenPct >= 0 ? .red : .green)
                }

                HStack {
                    Label("日内最高涨幅", systemImage: "arrow.up.right")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "+%.2f%%", summary.dayHighPct))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }

            // 文字描述
            if !summary.text.isEmpty {
                Divider()

                Text(summary.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.blue.opacity(0.05))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))  // 柔和的白灰色 #FAFAFA
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    /// 分时叙述卡片
    private func narrativeCard(narrative: Narrative) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: "text.quote")
                    .font(.title3)
                    .foregroundStyle(.orange)

                Text("分时叙述")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                if let early = narrative.early {
                    narrativeSection(title: "早盘", content: early, icon: "sunrise.fill", color: .blue)
                }

                if let midday = narrative.midday {
                    narrativeSection(title: "午盘", content: midday, icon: "sun.max.fill", color: .orange)
                }

                if let afternoon = narrative.afternoon {
                    narrativeSection(title: "午后", content: afternoon, icon: "sun.haze.fill", color: .yellow)
                }

                if let closing = narrative.closing {
                    narrativeSection(title: "尾盘", content: closing, icon: "sunset.fill", color: .purple)
                }
            }
        }
        .padding()
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))  // 柔和的白灰色 #FAFAFA
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    /// 叙述章节
    private func narrativeSection(title: String, content: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text(content)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(0.05))
                .cornerRadius(6)
        }
    }

    /// 交易单元卡片
    private func tradingUnitsCard(units: [TradingUnit]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.title3)
                    .foregroundStyle(.green)

                Text("交易单元")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("\(units.count) 个")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(units, id: \.index) { unit in
                tradingUnitRow(unit: unit)
            }
        }
        .padding()
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))  // 柔和的白灰色 #FAFAFA
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    /// 交易单元行
    private func tradingUnitRow(unit: TradingUnit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 时间和关系
            HStack {
                Text(unit.time)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(unit.relationship)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(relationshipColor(unit.relationship).opacity(0.2))
                    .foregroundStyle(relationshipColor(unit.relationship))
                    .cornerRadius(4)
            }

            // 价格变化
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("价格")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("$\(String(format: "%.2f", unit.priceFrom)) → $\(String(format: "%.2f", unit.priceTo))")
                        .font(.caption)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("变化")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%+.2f%%", unit.priceChangePct))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(unit.priceChangePct >= 0 ? .red : .green)
                }
            }

            // 关系描述
            Text(unit.relationshipDesc)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(Color(red: 1.0, green: 1.0, blue: 1.0).opacity(0.6))  // 半透明白色，更柔和
        .cornerRadius(8)
    }

    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("暂无分析数据")
                .font(.title3)
                .foregroundStyle(.secondary)

            Button("加载分析") {
                Task {
                    await viewModel.loadAnalysis()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helper Methods

    /// 关系类型颜色（长桥证券/亚洲市场配色：红涨绿跌）
    private func relationshipColor(_ relationship: String) -> Color {
        // 根据 README 中的9种量价关系配色方案
        switch relationship {
        // 上涨系列（红色系）
        case let r where r.contains("放量涨"):
            return Color(red: 0.9, green: 0.2, blue: 0.2)  // 🔴 深红 - 最强上涨信号
        case let r where r.contains("缩量涨"):
            return Color(red: 1.0, green: 0.8, blue: 0.0)  // 🟡 黄色 - 较弱上涨
        case let r where r.contains("持平涨"), let r where r.contains("正常量涨"):
            return Color(red: 1.0, green: 0.6, blue: 0.0)  // 🟠 橙色 - 中等上涨

        // 下跌系列（绿色/冷色系）
        case let r where r.contains("放量跌"):
            return Color(red: 0.0, green: 0.7, blue: 0.3)  // 🟢 绿色 - 最强下跌信号
        case let r where r.contains("缩量跌"):
            return Color(red: 0.2, green: 0.4, blue: 0.8)  // 🔵 蓝色 - 较弱下跌
        case let r where r.contains("持平跌"), let r where r.contains("正常量跌"):
            return Color(red: 0.5, green: 0.2, blue: 0.7)  // 🟣 紫色 - 中等下跌

        // 横盘系列（中性色）
        case let r where r.contains("放量平"):
            return Color(red: 1.0, green: 0.7, blue: 0.0)  // ⚠️ 金黄色 - 警告信号
        case let r where r.contains("缩量平"):
            return Color.gray.opacity(0.5)                  // ⚪ 浅灰 - 观望
        case let r where r.contains("持平平"), let r where r.contains("平静"):
            return Color.gray                               // ⚫ 灰色 - 无明显变化

        default:
            return Color.gray
        }
    }

    /// 分享分析报告
    private func shareAnalysis(_ analysis: String) {
        let activityVC = UIActivityViewController(
            activityItems: ["TSLL 分析报告\n\n\(analysis)"],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    TsllAnalysisView(
        authManager: .shared,
        apiClient: APIClient(authManager: .shared)
    )
}

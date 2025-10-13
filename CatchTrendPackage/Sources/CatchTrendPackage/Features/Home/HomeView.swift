//
//  HomeView.swift
//  CatchTrendPackage
//
//  Created by Claude Code on 2025/10/12.
//

import SwiftUI
import NetworkKit
import Shared

public struct HomeView: View {
    @State private var viewModel: HomeViewModel

    public init(authManager: AuthManager, apiClient: APIClient) {
        self._viewModel = State(wrappedValue: HomeViewModel(
            authManager: authManager,
            apiClient: apiClient
        ))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    // 加载状态
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("加载中...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if let data = viewModel.comprehensiveData {
                    // 数据显示
                    ScrollView {
                        VStack(spacing: 20) {
                            // 股票代码
                            Text(data.symbol)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            // 实时数据
                            if let realTime = data.realTime {
                                VStack(spacing: 8) {
                                    Text("$\(String(format: "%.2f", realTime.currentPrice ?? 0.0))")
                                        .font(.system(size: 48, weight: .bold))

                                    HStack(spacing: 4) {
                                        Image(systemName: (realTime.changePercent ?? 0.0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        Text(String(format: "%.2f%%", realTime.changePercent ?? 0.0))
                                    }
                                    .font(.title3)
                                    .foregroundStyle((realTime.changePercent ?? 0.0) >= 0 ? .green : .red)
                                }
                                .padding(.vertical)
                            }

                            // 数据详情
                            VStack(alignment: .leading, spacing: 12) {
                                if let dailyKline = data.dailyKline, let lastItem = dailyKline.data.last {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("日K线（最近）", systemImage: "chart.bar.fill")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        HStack(spacing: 8) {
                                            Text("开: $\(String(format: "%.2f", lastItem.open ?? 0))")
                                            Text("高: $\(String(format: "%.2f", lastItem.high ?? 0))")
                                            Text("低: $\(String(format: "%.2f", lastItem.low ?? 0))")
                                            Text("收: $\(String(format: "%.2f", lastItem.close ?? 0))")
                                        }
                                        .font(.caption)
                                    }
                                }

                                if let minuteKline = data.minuteKline, let lastItem = minuteKline.data.last {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("\(minuteKline.period) K线（最近）", systemImage: "chart.line.uptrend.xyaxis")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        HStack(spacing: 8) {
                                            Text("开: $\(String(format: "%.2f", lastItem.open ?? 0))")
                                            Text("高: $\(String(format: "%.2f", lastItem.high ?? 0))")
                                            Text("低: $\(String(format: "%.2f", lastItem.low ?? 0))")
                                            Text("收: $\(String(format: "%.2f", lastItem.close ?? 0))")
                                        }
                                        .font(.caption)
                                    }
                                }

                                if let minuteData = data.minuteData, let lastItem = minuteData.data.last {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Label("分时数据（最近）", systemImage: "clock.fill")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        HStack(spacing: 8) {
                                            Text("价格: $\(String(format: "%.2f", lastItem.price ?? 0))")
                                            Text("均价: $\(String(format: "%.2f", lastItem.avgPrice ?? 0))")
                                        }
                                        .font(.caption)
                                    }
                                }

                                Divider()

                                DataInfoRow(
                                    icon: "clock.arrow.circlepath",
                                    title: "更新时间",
                                    value: data.fetchTime
                                )
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)

                            // 错误提示
                            if !data.errors.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("部分数据获取失败", systemImage: "exclamationmark.triangle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.orange)

                                    ForEach(data.errors, id: \.self) { error in
                                        Text("• \(error)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                                .background(.orange.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }

                            // ChatGPT 分析按钮
                            Button {
                                Task {
                                    await viewModel.analyzeTrend()
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: viewModel.isAnalyzing ? "brain" : "sparkles")
                                        .font(.title3)

                                    Text(viewModel.isAnalyzing ? "分析中..." : "ChatGPT 趋势分析")
                                        .font(.headline)

                                    if viewModel.isAnalyzing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isAnalyzing)
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // 分析结果
                            if let analysis = viewModel.analysisResult {
                                VStack(alignment: .leading, spacing: 12) {
                                    Label("AI 分析结果", systemImage: "lightbulb.fill")
                                        .font(.headline)
                                        .foregroundStyle(.blue)

                                    Text(analysis)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding()
                                .background(.blue.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 60)
                        }
                        .padding(.vertical)
                    }
                } else {
                    // 空状态
                    VStack(spacing: 16) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("暂无数据")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("CatchTrend")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await viewModel.refreshData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("登出") {
                        viewModel.logout()
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .task {
                await viewModel.loadData()
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
}

// MARK: - Supporting Views

/// 数据信息行组件
private struct DataInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        authManager: .shared,
        apiClient: APIClient(authManager: .shared)
    )
}

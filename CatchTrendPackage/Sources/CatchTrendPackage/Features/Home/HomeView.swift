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
                                    Text("¥\(String(format: "%.2f", realTime.currentPrice ?? 0.0))")
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
                                if let dailyKline = data.dailyKline {
                                    DataInfoRow(
                                        icon: "chart.bar.fill",
                                        title: "日K线数据",
                                        value: "\(dailyKline.data.count) 条"
                                    )
                                }

                                if let minuteKline = data.minuteKline {
                                    DataInfoRow(
                                        icon: "chart.line.uptrend.xyaxis",
                                        title: "分钟K线数据",
                                        value: "\(minuteKline.data.count) 条"
                                    )
                                }

                                if let minuteData = data.minuteData {
                                    DataInfoRow(
                                        icon: "clock.fill",
                                        title: "分时数据",
                                        value: "\(minuteData.data.count) 条"
                                    )
                                }

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

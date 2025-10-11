import SwiftUI
import StockKit

struct ContentView: View {
    @Environment(StockService.self) var stockService
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if stockService.isLoading {
                    ProgressView("加载中...")
                        .progressViewStyle(.circular)
                } else if let data = stockService.comprehensiveData {
                    StockDataView(data: data)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Strategy iOS")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("股票数据分析应用")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: {
                            Task {
                                do {
                                    _ = try await stockService.fetchComprehensiveData(symbol: "CONL")
                                } catch {
                                    showError = true
                                }
                            }
                        }) {
                            Label("获取 CONL 数据", systemImage: "arrow.down.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Strategy iOS")
            .alert("错误", isPresented: $showError) {
                Button("确定") {
                    stockService.clearError()
                }
            } message: {
                if let error = stockService.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

struct StockDataView: View {
    let data: ComprehensiveStockData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 实时行情
                if let realtime = data.realtime {
                    RealtimeCardView(realtime: realtime)
                }

                // K线数据
                if let kline = data.kline, !kline.isEmpty {
                    KLineCardView(kline: kline)
                }

                // 分时数据
                if let minute = data.minute, !minute.isEmpty {
                    MinuteCardView(minute: minute)
                }
            }
            .padding()
        }
    }
}

struct RealtimeCardView: View {
    let realtime: RealtimeData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("实时行情")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(realtime.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(realtime.symbol)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("¥\(realtime.currentPrice, specifier: "%.2f")")
                        .font(.system(size: 32, weight: .bold))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(realtime.changeAmount >= 0 ? "+" : "")\(realtime.changeAmount, specifier: "%.2f")")
                            .font(.subheadline)
                        Text("\(realtime.changePercent >= 0 ? "+" : "")\(realtime.changePercent, specifier: "%.2f")%")
                            .font(.subheadline)
                    }
                    .foregroundColor(realtime.changePercent >= 0 ? .red : .green)
                }

                Divider()

                HStack {
                    VStack(alignment: .leading) {
                        Text("最高")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("¥\(realtime.high, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("最低")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("¥\(realtime.low, specifier: "%.2f")")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("成交量")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(realtime.volume)")
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct KLineCardView: View {
    let kline: [KLineItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("K线数据")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("共 \(kline.count) 条数据")
                    .font(.subheadline)

                if let latest = kline.first {
                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("最新K线")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("开盘")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(latest.open, specifier: "%.2f")")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("收盘")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(latest.close, specifier: "%.2f")")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("最高")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(latest.high, specifier: "%.2f")")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("最低")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(latest.low, specifier: "%.2f")")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct MinuteCardView: View {
    let minute: [MinuteItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分时数据")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("共 \(minute.count) 条数据")
                    .font(.subheadline)

                if let latest = minute.first {
                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("最新分时")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("价格")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(latest.price, specifier: "%.2f")")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("成交量")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(latest.volume)")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("成交额")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("¥\(latest.amount, specifier: "%.2f")")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

#Preview {
    ContentView()
        .environment(StockService())
}

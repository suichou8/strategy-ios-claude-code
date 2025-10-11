# Feature: 获取CONL综合股票数据

## 分支信息
- **分支名称**: `feature/fetch-data-conl`
- **功能**: 实现获取CONL股票的综合数据（实时行情 + K线 + 分时）

## 实现内容

### 1. 数据模型
**文件**: `Features/Stock/Models/ComprehensiveStockData.swift`

定义了以下数据结构：
- `ComprehensiveStockResponse`: 综合数据响应
- `ComprehensiveStockData`: 综合数据容器（包含实时、K线、分时）
- `RealtimeData`: 实时行情数据
- `KLineItem`: K线数据项
- `MinuteItem`: 分时数据项
- `KLinePeriod`: K线周期枚举

### 2. 网络层
**文件**:
- `Core/Network/NetworkError.swift`: 网络错误定义
- `Core/Network/APIEndpoint.swift`: API端点定义
- `Core/Network/APIClient.swift`: API客户端实现

**特性**:
- 使用 `async/await` 进行异步网络请求
- 自动添加时间戳参数绕过CDN缓存
- 支持JWT Token认证（从Keychain读取）
- 完整的错误处理机制

### 3. Keychain管理
**文件**: `Core/Utilities/KeychainManager.swift`

用于安全存储和读取JWT Token。

### 4. 股票服务
**文件**: `Features/Stock/Services/StockService.swift`

提供综合股票数据获取服务：
- `fetchComprehensiveData(symbol:)`: 获取指定股票的综合数据
- 使用 `@Observable` 支持SwiftUI响应式更新
- 自动管理加载状态和错误状态

## 使用示例

### 基础使用

```swift
import SwiftUI

struct ContentView: View {
    @State private var stockService = StockService()
    @State private var showError = false

    var body: some View {
        VStack {
            if stockService.isLoading {
                ProgressView("加载中...")
            } else if let data = stockService.comprehensiveData {
                // 显示实时数据
                if let realtime = data.realtime {
                    VStack(alignment: .leading) {
                        Text(realtime.name)
                            .font(.title)
                        Text("当前价: ¥\(realtime.currentPrice, specifier: "%.2f")")
                        Text("涨跌幅: \(realtime.changePercent, specifier: "%.2f")%")
                            .foregroundColor(realtime.changePercent >= 0 ? .red : .green)
                    }
                }

                // 显示K线数据
                if let kline = data.kline {
                    Text("K线数据: \(kline.count)条")
                }

                // 显示分时数据
                if let minute = data.minute {
                    Text("分时数据: \(minute.count)条")
                }
            }

            Button("获取CONL数据") {
                Task {
                    do {
                        _ = try await stockService.fetchComprehensiveData(symbol: "CONL")
                    } catch {
                        showError = true
                    }
                }
            }
        }
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
```

### ViewModel使用

```swift
import SwiftUI
import Observation

@Observable
class StockViewModel {
    var stockService: StockService
    var showError = false

    init(stockService: StockService = StockService()) {
        self.stockService = stockService
    }

    func loadStockData(symbol: String) async {
        do {
            _ = try await stockService.fetchComprehensiveData(symbol: symbol)
        } catch {
            showError = true
        }
    }
}

struct StockView: View {
    @State private var viewModel = StockViewModel()

    var body: some View {
        // 使用 viewModel.stockService.comprehensiveData
        Text("Stock View")
            .task {
                await viewModel.loadStockData(symbol: "CONL")
            }
    }
}
```

## API端点

### 综合数据端点
```
GET /api/v1/stocks/{symbol}/comprehensive
```

**参数**:
- `symbol`: 股票代码（例如: CONL）
- `timestamp`: 时间戳（自动添加，用于绕过缓存）

**认证**: 需要JWT Token（Bearer Token）

**响应示例**:
```json
{
  "success": true,
  "message": "获取成功",
  "data": {
    "realtime": {
      "symbol": "CONL",
      "name": "康龙化成",
      "current_price": 45.67,
      "change_amount": 1.23,
      "change_percent": 2.76,
      "high": 46.00,
      "low": 44.50,
      "open": 44.80,
      "previous_close": 44.44,
      "volume": 1234567,
      "amount": 56789012.34,
      "timestamp": "2024-10-12 14:30:00"
    },
    "kline": [
      {
        "datetime": "2024-10-12 09:30:00",
        "open": 44.80,
        "high": 45.20,
        "low": 44.50,
        "close": 45.00,
        "volume": 123456
      }
    ],
    "minute": [
      {
        "datetime": "2024-10-12 09:31:00",
        "price": 45.10,
        "volume": 12345,
        "amount": 556789.50
      }
    ]
  }
}
```

## 技术要点

1. **最小化原则**: 只实现获取综合数据所需的最小代码集
2. **iOS 17+**: 使用 `@Observable` 宏（需要iOS 17+）
3. **Actor隔离**: APIClient使用actor保证线程安全
4. **安全存储**: JWT Token存储在Keychain中
5. **错误处理**: 完整的错误处理和用户友好的错误信息
6. **缓存绕过**: 自动添加时间戳参数获取最新数据

## 依赖要求

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## 注意事项

1. 使用前需要先登录并获取JWT Token存储到Keychain
2. 股票代码会自动转换为大写格式
3. 网络请求失败会抛出具体的错误信息
4. 建议在Task或async上下文中调用服务方法

## 后续扩展

当前实现聚焦于综合数据获取，未来可以扩展：
- 单独的K线数据获取接口
- 单独的分时数据获取接口
- 单独的实时数据获取接口
- 数据缓存机制（SwiftData）
- 用户认证功能
- 图表展示组件

---
*创建时间: 2024-10-12*
*分支: feature/fetch-data-conl*

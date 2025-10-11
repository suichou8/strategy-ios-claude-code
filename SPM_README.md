# Swift Package Manager 模块化说明

## 项目结构

本项目已经使用 Swift Package Manager (SPM) 进行模块化管理，将代码分为三个独立的模块：

```
strategy-ios-claude-code/
├── Package.swift                 # SPM 包定义文件
├── Sources/
│   ├── SecurityKit/              # 安全模块
│   │   └── KeychainManager.swift
│   ├── NetworkKit/               # 网络层模块
│   │   ├── NetworkError.swift
│   │   ├── APIEndpoint.swift
│   │   └── APIClient.swift
│   └── StockKit/                 # 股票业务模块
│       ├── Models/
│       │   └── ComprehensiveStockData.swift
│       └── Services/
│           └── StockService.swift
└── Tests/
    ├── SecurityKitTests/
    ├── NetworkKitTests/
    └── StockKitTests/
```

## 模块说明

### 1. SecurityKit
**功能**: 提供安全相关功能，主要是 Keychain 管理

**依赖**: 无

**导出的公共接口**:
- `KeychainManager`: Keychain 管理器
- `KeychainError`: Keychain 错误类型

**使用示例**:
```swift
import SecurityKit

// 保存 Token
try KeychainManager.shared.save("your_token", forKey: "auth_token")

// 读取 Token
let token = try KeychainManager.shared.load(forKey: "auth_token")

// 删除 Token
KeychainManager.shared.delete(forKey: "auth_token")
```

### 2. NetworkKit
**功能**: 提供网络请求基础设施

**依赖**: SecurityKit

**导出的公共接口**:
- `APIClient`: API 客户端 (actor)
- `APIEndpoint`: API 端点枚举
- `HTTPMethod`: HTTP 方法枚举
- `NetworkError`: 网络错误类型

**使用示例**:
```swift
import NetworkKit

// 创建 API 客户端
let apiClient = APIClient.shared

// 发起请求
let response = try await apiClient.request(
    .comprehensive(symbol: "CONL"),
    responseType: YourResponseType.self
)
```

### 3. StockKit
**功能**: 股票业务逻辑和数据模型

**依赖**: NetworkKit, SecurityKit

**导出的公共接口**:
- **Models**:
  - `ComprehensiveStockResponse`: 综合数据响应
  - `ComprehensiveStockData`: 综合数据
  - `RealtimeData`: 实时行情
  - `KLineItem`: K线数据项
  - `MinuteItem`: 分时数据项
  - `KLinePeriod`: K线周期枚举

- **Services**:
  - `StockService`: 股票数据服务 (@Observable)

**使用示例**:
```swift
import SwiftUI
import StockKit

@Observable
class ViewModel {
    let stockService = StockService()

    func loadData() async {
        do {
            let data = try await stockService.fetchComprehensiveData(symbol: "CONL")
            // 处理数据
            print("实时价格: \(data.realtime?.currentPrice ?? 0)")
        } catch {
            print("错误: \(error)")
        }
    }
}
```

## 模块依赖关系

```
StockKit
    ├── NetworkKit
    │   └── SecurityKit
    └── SecurityKit

NetworkKit
    └── SecurityKit

SecurityKit
    (无依赖)
```

## 在 Xcode 中使用

### 方式一：直接在 Xcode 中打开

1. 双击 `Package.swift` 文件，或在 Xcode 中选择 `File -> Open`
2. 选择项目根目录（包含 `Package.swift` 的目录）
3. Xcode 会自动识别为 SPM 包并打开

### 方式二：添加到现有 iOS 项目

1. 在 Xcode 中打开你的 iOS 项目
2. 选择项目文件，进入 `Package Dependencies` 标签页
3. 点击 `+` 按钮添加本地包
4. 选择本项目的根目录
5. 选择需要的模块（SecurityKit, NetworkKit, StockKit）

### 方式三：作为远程依赖

如果代码已经推送到 Git 仓库，可以直接添加远程依赖：

```swift
// 在你的 Package.swift 中
dependencies: [
    .package(url: "https://github.com/your-username/strategy-ios-claude-code.git", from: "1.0.0")
]

// 在 target 的依赖中
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "StockKit", package: "strategy-ios-claude-code"),
        .product(name: "NetworkKit", package: "strategy-ios-claude-code"),
        .product(name: "SecurityKit", package: "strategy-ios-claude-code")
    ]
)
```

## 命令行使用

### 构建项目
```bash
swift build
```

### 运行测试
```bash
swift test
```

### 清理构建
```bash
swift package clean
```

### 解析依赖
```bash
swift package resolve
```

### 更新依赖
```bash
swift package update
```

### 生成 Xcode 项目（可选）
```bash
swift package generate-xcodeproj
```

## 在 iOS App 中集成示例

### 1. 创建 iOS App 项目

```bash
# 在项目根目录创建一个新的 iOS App
mkdir StrategyiOSApp
cd StrategyiOSApp
```

### 2. 在 App 的 Package.swift 中添加依赖

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StrategyiOSApp",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        // 添加本地依赖
        .package(path: "../")  // 指向包含 StockKit 等模块的目录
    ],
    targets: [
        .target(
            name: "StrategyiOSApp",
            dependencies: [
                .product(name: "StockKit", package: "strategy-ios-claude-code"),
            ]
        )
    ]
)
```

### 3. 在 SwiftUI 中使用

```swift
import SwiftUI
import StockKit

@main
struct StrategyiOSApp: App {
    @State private var stockService = StockService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stockService)
        }
    }
}

struct ContentView: View {
    @Environment(StockService.self) var stockService
    @State private var showError = false

    var body: some View {
        VStack {
            if stockService.isLoading {
                ProgressView("加载中...")
            } else if let data = stockService.comprehensiveData {
                StockDataView(data: data)
            } else {
                Button("获取 CONL 数据") {
                    Task {
                        do {
                            _ = try await stockService.fetchComprehensiveData(symbol: "CONL")
                        } catch {
                            showError = true
                        }
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

struct StockDataView: View {
    let data: ComprehensiveStockData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let realtime = data.realtime {
                VStack(alignment: .leading) {
                    Text(realtime.name)
                        .font(.title)
                    Text("当前价: ¥\(realtime.currentPrice, specifier: "%.2f")")
                        .font(.headline)
                    Text("涨跌幅: \(realtime.changePercent, specifier: "%.2f")%")
                        .foregroundColor(realtime.changePercent >= 0 ? .red : .green)
                }
            }

            if let kline = data.kline {
                Text("K线数据: \(kline.count) 条")
            }

            if let minute = data.minute {
                Text("分时数据: \(minute.count) 条")
            }
        }
        .padding()
    }
}
```

## 模块化优势

1. **职责清晰**: 每个模块负责特定功能，易于维护
2. **可重用性**: 模块可以在多个项目中重用
3. **依赖管理**: 清晰的依赖关系，避免循环依赖
4. **独立测试**: 每个模块可以独立测试
5. **编译优化**: 只重新编译改动的模块
6. **代码隔离**: 模块间通过公共接口通信，内部实现隔离

## 注意事项

1. **访问控制**:
   - 需要被外部使用的类型、方法必须标记为 `public`
   - 模块内部使用的保持默认 `internal` 访问级别

2. **iOS 版本要求**:
   - 最低支持 iOS 17.0
   - 使用了 `@Observable` 宏（iOS 17+ 新特性）

3. **导入语句**:
   - 使用时需要明确导入模块：`import StockKit`, `import NetworkKit`, `import SecurityKit`

4. **线程安全**:
   - `APIClient` 使用 `actor` 实现线程安全
   - `StockService` 使用 `@Observable` 宏，状态更新自动在主线程

## 故障排查

### 问题：无法解析依赖
```bash
# 清理并重新解析
rm -rf .build
swift package clean
swift package resolve
```

### 问题：Xcode 无法识别模块
1. 关闭 Xcode
2. 删除 DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. 重新打开项目

### 问题：模块编译错误
- 检查 Swift 版本是否 >= 5.9
- 检查 iOS 部署目标是否 >= 17.0
- 确保所有公共接口都标记了 `public`

## 下一步

- [ ] 添加单元测试
- [ ] 添加 CI/CD 集成
- [ ] 添加更多 API 端点
- [ ] 实现数据缓存机制
- [ ] 添加用户认证模块

---
*最后更新: 2024-10-12*
*Swift Package Manager 版本: 5.9+*
